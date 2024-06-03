import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries-db-schema.dart';
import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/transfer-queue/transfer-queue.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:sqflite/sqflite.dart';

class OfflinedEntries with ChangeNotifier {
  static const dbName = 'offlined_entries.sql';
  static const filesPath = 'offlined-files';
  static const syncTaskName = 'syncOfflineEntries';

  OfflinedEntries(this.entriesApi, this.transferQueue) {
    db = openDatabase(
        '${entriesApi.localStorage.permanent.rootDir.path}/${OfflinedEntries.dbName}',
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(OFFLINED_ENTRIES_DB_SCHEMA);
    });

    localStorage = entriesApi.localStorage.permanent
        .scopedToSubDir(OfflinedEntries.filesPath);

    _query(column: 'id').then((value) {
      offlinedEntryIds = List<int?>.from(value);
      notifyListeners();
    });

    _bindBackgroundIsolate();
  }

  Future<Database>? db;
  final FileEntriesApi entriesApi;
  final TransferQueue transferQueue;
  List<int?> offlinedEntryIds = [];
  late LocalStorageAdapter localStorage;
  ReceivePort _syncPort = ReceivePort();

  String getPath(FileEntry fileEntry) {
    return '${localStorage.rootDir.path}/${fileEntry.fileName}.${fileEntry.extension}';
  }

  bool isFullyDownloaded(FileEntry fileEntry) {
    final file = File(getPath(fileEntry));
    return file.existsSync() && file.lengthSync() == fileEntry.fileSize;
  }

  offline(List<FileEntry> entries, {BuildContext? context}) async {
    entries = (await _fetchChildEntries(entries))
        .where((e) => !offlinedEntryIds.contains(e))
        .toList();
    final batch = (await db)!.batch();

    entries.forEach((entry) async {
      final fingerprint = await transferQueue.addDownload(
        entry,
        getPath(entry),
        type: FileTransferType.offline,
      );
      if (fingerprint != null) {
        offlinedEntryIds.add(entry.id);
        _insert(entry, fingerprint, batch);
      }
    });
    batch.commit();
    notifyListeners();
  }

  unoffline(List<FileEntry?> entries) async {
    final allDeletedEntries = await _delete(entries);
    allDeletedEntries.forEach((entry) {
      offlinedEntryIds.remove(entry.id);
      localStorage.delete(entry.fileName);
      transferQueue.cancelTransfer(entry.downloadFingerprint);
    });
    notifyListeners();
  }

  sync() async {
    List<String> fileNames = [];
    localStorage.rootDir
        .listSync(recursive: true, followLinks: false)
        .forEach((e) {
      if (e is File) fileNames.add(basename(e.path));
    });
    if (fileNames.isNotEmpty) {
      List<String?> syncInfo = (await entriesApi.getSyncInfo(fileNames))
          .map((e) => e.fileName)
          .toList();
      List<String> filesToDelete = fileNames
        ..removeWhere((e) => syncInfo.contains(e));
      filesToDelete.forEach((e) => localStorage.delete(e));
      List<Map<String, dynamic>> result = await (await db)!.query('entries',
          where: 'file_name in (?)', whereArgs: [filesToDelete.join(',')]);
      List<int> deletedEntryIds = List.from(result.map((e) => e['id']));
      (await db)!.delete('entries',
          where: 'file_name in (?)', whereArgs: [filesToDelete.join(',')]);
      offlinedEntryIds.removeWhere((e) => deletedEntryIds.contains(e));
    }
  }

  Future<Map<String, dynamic>> loadEntries(int page,
      {required Map<String, String?> params}) async {
    final offset = (page - 1) * DriveState.perPage;
    final limit = page + DriveState.perPage;
    final parentId = params['parentId'].toString();
    final parentIdOperator = parentId == 'null' ? 'is' : '=';
    final result = await (await db)!.query(
      'entries',
      offset: offset,
      limit: limit,
      orderBy:
          '${ReCase(params['orderBy']!).snakeCase} ${ReCase(params['orderDir']!).snakeCase}',
      where: 'parent_id $parentIdOperator $parentId',
    );
    final total = Sqflite.firstIntValue(await (await db)!.rawQuery(
        'SELECT COUNT(*) FROM entries where parent_id $parentIdOperator $parentId'))!;
    return {
      'current_page': page,
      'from': offset,
      'last_page': max((total / DriveState.perPage).ceil(), 1),
      'per_page': DriveState.perPage,
      'to': limit,
      'total': total,
      'data': List<dynamic>.from(result.map((e) => e)),
    };
  }

  Future<int> update(FileEntry entry) async {
    return (await db)!.update('entries', entry.toJson(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future close() async => (await db)!.close();

  Future<List<dynamic>> _query({List<int?>? parentIds, String? column}) async {
    final columns = column != null ? [column] : null;
    List<Map<String, dynamic>> result;
    if (parentIds == null) {
      result = await (await db)!.query('entries', columns: columns);
    } else {
      result = await (await db)!.query('entries',
          where: 'parent_id in (?)',
          whereArgs: [parentIds.join(',')],
          columns: columns);
    }
    return List.from(
        result.map((e) => column == null ? FileEntry.fromJson(e) : e[column]));
  }

  _insert(FileEntry entry, String fingerprint, Batch batch) async {
    final json = entry.toJson(forLocalSql: true);
    json['download_fingerprint'] = fingerprint;
    batch.insert('entries', json);
  }

  Future<List<FileEntry>> _delete(List<FileEntry?> entries) async {
    List<int?> parentIds =
        entries.where((e) => e!.type == 'folder').map((e) => e!.id).toList();
    List<int> childIds = parentIds.isNotEmpty
        ? List<int>.from((await _query(parentIds: parentIds)))
        : [];
    List<int?> allIds = entries.map((e) => e!.id).toList()..addAll(childIds);
    List<FileEntry> allEntries = List<FileEntry>.from((await _query()));
    (await db)!
        .delete('entries', where: 'id in (?)', whereArgs: [allIds.join(',')]);
    return allEntries;
  }

  Future<List<FileEntry>> _fetchChildEntries(List<FileEntry> entries) async {
    final folders = entries.where((e) => e.type == 'folder');
    if (folders.isNotEmpty) {
      try {
        final response = await entriesApi.loadEntries({
          'perPage': '1000',
          'parentIds': folders.map((e) => e.id).join(','),
        });
        final childEntries = List.from(json.decode(response)['data'])
            .map((e) => FileEntry.fromJson(e));
        entries.addAll(childEntries);
      } on BackendError catch (_) {
        //
      }
    }
    return entries;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _syncPort.sendPort, OfflinedEntries.syncTaskName);
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _syncPort.listen((_) {
      sync();
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(OfflinedEntries.syncTaskName);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
}

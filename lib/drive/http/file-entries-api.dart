import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/screens/destination-picker/entry-move-type.dart';
import 'package:bedrive/drive/screens/manage-users/sharee-payload.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link.dart';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/offlined-entries/entry-sync-info.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:dio/dio.dart';

class FileEntriesApi {
  FileEntriesApi(this.http, this.localStorage);
  final AppHttpClient? http;
  final LocalStorage localStorage;

  String? previewUrl(FileEntry fileEntry) {
    if (fileEntry.url!.startsWith('http')) {
      return fileEntry.url;
    } else {
      var previewUrl = fileEntry.url!.replaceFirst('secure/', 'api/v1/');
      previewUrl += '?accessToken=${Uri.encodeComponent(http!.accessToken!)}';
      return '${http!.baseBackendUrl}/$previewUrl';
    }
  }

  String downloadUrl(List<FileEntry> entries) {
    String hashes = entries.map((e) => e.hash).join(',');
    return '${http!.backendApiUrl}/file-entries/download/$hashes?accessToken=${http!.accessToken}';
  }

  Future<String> getFileContents(FileEntry fileEntry,
      {String? parentId}) async {
    final options = new Options(headers: {'Content-type': 'text/plain'});
    return http!.get(previewUrl(fileEntry)!, options: options);
  }

  Future<String> loadEntries(Map<String, String?> params,
      {CancelToken? cancelToken}) {
    return http!.get('/drive/file-entries',
        params: params,
        options: Options(responseType: ResponseType.plain),
        cancelToken: cancelToken);
  }

  Future<FileEntry> renameFile(int? id,
      {String? name, String? description}) async {
    final response = await http!
        .put('/file-entries/$id', {'name': name, 'description': description});
    return FileEntry.fromJson(response['fileEntry']);
  }

  Future<List<FileEntryUser>> addUsers(int entryId, List<String> emails,
      SharedEntryPermissions permissions) {
    return http!.post('/file-entries/$entryId/share', payload: {
      'emails': emails,
      'permissions': permissions
    }).then((response) {
      return (response['users'] as Iterable)
          .map((u) => FileEntryUser.fromJson(u))
          .toList();
    });
  }

  Future<List<FileEntryUser>> changePermissions(
      int entryId, ShareePayload sharee) {
    return http!.put('/file-entries/$entryId/change-permissions', {
      'userId': sharee.id,
      'permissions': sharee.permissions
    }).then((response) {
      return (response['users'] as Iterable)
          .map((u) => FileEntryUser.fromJson(u))
          .toList();
    });
  }

  Future<List<FileEntryUser>> removeUser(int entryId, int? userId) {
    return http!.post('/file-entries/$entryId/unshare',
        payload: {'userId': userId}).then((response) {
      return (response['users'] as Iterable)
          .map((u) => FileEntryUser.fromJson(u))
          .toList();
    });
  }

  Future<ShareableLink> fetchLink(int? entryId) {
    return http!.get('/file-entries/$entryId/shareable-link').then((response) {
      return ShareableLink.fromJson(response['link']);
    });
  }

  Future<ShareableLink> crupdateLink(
      int? entryId, ShareableLink? link, Map<String, dynamic> values) {
    final request = link == null
        ? http!.post('/file-entries/$entryId/shareable-link', payload: values)
        : http!.put('/file-entries/$entryId/shareable-link', values);
    return request.then((response) {
      return ShareableLink.fromJson(response['link']);
    });
  }

  Future<void> deleteLink(int? entryId) {
    return http!.delete('/file-entries/$entryId/shareable-link');
  }

  Future<void> deleteFiles(List<int?> fileIds, {bool deleteForever = false}) {
    return http!.post(
        '/file-entries/delete', payload: {'entryIds': fileIds, 'deleteForever': deleteForever});
  }

  Future<void> restoreEntries(List<int?> entryIds) {
    return http!.post('/file-entries/restore', payload: {'entryIds': entryIds});
  }

  Future<List<FileEntry>> moveOrCopyEntries(
      List<int?> fileIds, int? destination, EntryMoveType moveType) async {
    final endpoint = moveType == EntryMoveType.move ? 'move' : 'duplicate';
    final response = await http!.post('/file-entries/$endpoint',
        payload: {'entryIds': fileIds, 'destinationId': destination});
    return (response['entries'] as Iterable)
        .map((f) => FileEntry.fromJson(f))
        .toList();
  }

  Future<FileEntry> createFolder(String? name, {parentId: int}) async {
    final response = await http!
        .post('/folders', payload: {'name': name, 'parentId': parentId});
    return FileEntry.fromJson(response['folder']);
  }

  Future<dynamic> addToStarred(List<int?> entryIds) {
    return http!.post('/file-entries/star', payload: {'entryIds': entryIds});
  }

  Future<dynamic> removeFromStarred(List<int?> entryIds) {
    return http!.post('/file-entries/unstar', payload: {'entryIds': entryIds});
  }

  Future<List<EntrySyncInfo>> getSyncInfo(List<String> fileNames) async {
    final response = await http!
        .post('/file-entries/sync-info', payload: {'fileNames': fileNames});
    return (response['entries'] as Iterable)
        .map((e) => EntrySyncInfo.fromJson(e))
        .toList();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bedrive/drive/dialogs/confirm-file-deletion-dialog.dart';
import 'package:bedrive/drive/dialogs/loading-dialog.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/http/pagination.dart';
import 'package:bedrive/drive/navigation/app-bar/file-list-bar/sorting/file-sort-options.dart';
import 'package:bedrive/drive/screens/destination-picker/entry-move-type.dart';
import 'package:bedrive/drive/state/entry-cache.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/transfers/transfer-queue/transfer-queue.dart';
import 'package:bedrive/transfers/uploads/file-upload.dart';
import 'package:bedrive/utils/text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DriveState with ChangeNotifier {
  static const perPage = 25;

  DriveState(
      {required this.api,
        required this.entryCache,
        required this.offlinedEntriesDB,
        required this.transferQueue,
        this.activePage}) {
    _bindToScrollController();
    if (activePage == null) {
      activePage = RootFolderPage();
    }
    // load initial entries
    if (activePage is! SearchPage) {
      loadEntries(1);
    }
    transferQueueSub = transferQueue.uploadCompleted.listen((e) {
      if (activePage is RootFolderPage || activePage is FolderPage) {
        // user will have all permissions for files they uploaded
        e.permissions = [
          EntryPermission.download,
          EntryPermission.update,
          EntryPermission.delete
        ];
        addEntries([e]);
        notifyListeners();
      }
    });
  }

  final FileEntriesApi api;
  final EntryCache entryCache;
  final OfflinedEntries offlinedEntriesDB;
  final TransferQueue transferQueue;
  CancelToken? cancelToken;
  late StreamSubscription<FileEntry> transferQueueSub;
  final scrollController = ScrollController();

  FilePage? activePage;
  List<int> selectedEntries = [];

  List<int> entries = [];
  Pagination pagination = Pagination();
  bool isLoadingFromBackend = false;
  BackendError? lastBackendError;

  dispose() {
    transferQueueSub.cancel();
    if (cancelToken != null && !cancelToken!.isCancelled) {
      cancelToken!.cancel();
    }
    scrollController.dispose();
    super.dispose();
  }

  deselectAll() {
    selectedEntries = [];
    notifyListeners();
  }

  selectAll() {
    selectedEntries = List.from(this.entries);
    notifyListeners();
  }

  toggleEntry(FileEntry entry) {
    final newList = [...selectedEntries];
    newList.contains(entry.id)
        ? newList.remove(entry.id)
        : newList.add(entry.id);
    selectedEntries = newList;
    notifyListeners();
  }

  openPage(FilePage page) {
    if (activePage!.uniqueId != page.uniqueId) {
      clearEntries();
      scrollTo(0);
      activePage = page;
      selectedEntries = [];
      loadEntries(1);
    }
  }

  changeSort(EntrySortColumn column, EntrySortDirection direction) {
    activePage!.sortColumn = column;
    activePage!.sortDirection = direction;
    reloadEntries();
  }

  setSearchFilter(String name, String? value, {bool reload = true}) {
    if (value == activePage!.staticQueryParams![name]) return;
    activePage!.staticQueryParams![name] = value;
    if (reload) {
      reloadEntries();
    }
    notifyListeners();
  }

  uploadFiles(List<String?> files) {
    final parentId = activePage!.staticQueryParams!['folderId'];
    files.forEach((filePath) {
      final fileUpload = FileUpload(filePath!, parentId);
      transferQueue.addUpload(fileUpload);
    });
  }

  Future<FileEntry> renameFile(FileEntry fileEntry,
      {String? name, String? description}) async {
    final entry = await api.renameFile(fileEntry.id,
        name: name, description: description);
    final oldEntry = entryCache.get(entry.id);
    if (oldEntry != null) {
      oldEntry.name = name ?? oldEntry.name;
      oldEntry.description = description ?? oldEntry.description;
      entryCache.set(entry.id, oldEntry);
      notifyListeners();
      return oldEntry;
    }
    return entry;
  }

  unshare(int entryId, int? userId) async {
    final users = await api.removeUser(entryId, userId);
    if (activePage is SharesPage) {
      removeEntries([entryId]);
    }
    return updateEntryUsers([entryId], users);
  }

  List<FileEntryUser> updateEntryUsers(
      List<int> entryIds, List<FileEntryUser> users) {
    entryIds.forEach((id) => entryCache.get(id)!.users = users);
    notifyListeners();
    return users;
  }

  Future<void> deleteEntries(List<int?> entryIds,
      {bool deleteForever = false}) async {
    final confirmed = await showConfirmationDialog(
      rootNavigatorKey.currentContext!,
      title: 'Delete',
      subtitle: 'Are you sure you want to delete selected files?',
      confirmText: 'Delete',
    );
    if (confirmed != null && confirmed) {
      LoadingDialog.show(message: trans('Deleting...'));
      try {
        await api.deleteFiles(entryIds, deleteForever: deleteForever);
        removeEntries(entryIds);
      } finally {
        LoadingDialog.hide();
        notifyListeners();
      }
    }
  }

  Future<void> restoreEntries(List<int?> entryIds,
      {bool deleteForever = false}) async {
    LoadingDialog.show(message: trans('Restoring...'));
    try {
      await api.restoreEntries(entryIds);
      removeEntries(entryIds);
    } finally {
      LoadingDialog.hide();
      notifyListeners();
    }
  }

  Future<List<FileEntry>> moveOrCopyEntries(List<FileEntry?> targetEntries,
      int? destinationId, EntryMoveType moveType) async {
    final targetIds = targetEntries.map((f) => f!.id).toList();
    final response =
    await api.moveOrCopyEntries(targetIds, destinationId, moveType);
    if (moveType == EntryMoveType.move) {
      removeEntries(targetEntries.map((e) => e!.id).toList());
    } else {
      addEntries(response);
    }
    notifyListeners();
    return response;
  }

  Future<FileEntry> createFolder(String? name) async {
    final parentId = activePage!.staticQueryParams!['folderId'];
    final newFolder = await api.createFolder(name, parentId: parentId);
    addEntries([newFolder]);
    notifyListeners();
    return newFolder;
  }

  addToStarred(List<int> ids) async {
    await api.addToStarred(ids);
    ids.forEach((id) {
      entryCache.get(id)!.addToStarred();
    });
    notifyListeners();
  }

  removeFromStarred(List<int> ids) async {
    await api.removeFromStarred(ids);
    ids.forEach((id) {
      entryCache.get(id)!.removeFromStarred();
    });
    notifyListeners();
  }

  addEntries(List<FileEntry> newEntries) {
    if (newEntries.isNotEmpty) {
      final newEntriesList = [...entries];
      int folderCount = newEntriesList
          .where((id) => entryCache.get(id)!.type == 'folder')
          .length;
      newEntries.forEach((entry) {
        entryCache.set(entry.id, entry);
        newEntriesList.insert(folderCount, entry.id);
      });
      entries = newEntriesList;
    }
  }

  removeEntries(List<int?> entryIds, {bool notify = false}) {
    final newEntriesList = [...entries];
    newEntriesList.removeWhere((id) => entryIds.contains(id));
    entries = newEntriesList;
    pagination.total = max(pagination.total! - entryIds.length, 0);
    if (notify) {
      notifyListeners();
    }
  }

  clearEntries() {
    pagination = Pagination();
    entries = [];
  }

  Future<void> reloadEntries() async {
    deselectAll();
    scrollTo(0);
    clearEntries();
    await loadEntries(1);
  }

  scrollTo(double value) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(value);
    }
  }

  Future<void> loadEntries(int page) async {
    isLoadingFromBackend = true;
    if (cancelToken != null && cancelToken!.isCancelled == false) {
      cancelToken!.cancel();
    }
    cancelToken = CancelToken();

    final params = activePage!.getQueryParams(page);

    try {
      bool skipLoad = params.keys.contains('skipLoadFromBackend');
      final liveResponse = skipLoad
          ? await Future.value(null)
          : await api.loadEntries(params, cancelToken: cancelToken);
      cancelToken = null;
      if (liveResponse != null) {
        entryCache.cacheResponse(liveResponse, params);
      }
      _handleRawLoadedEntriesResponse(page, liveResponse);
    } on BackendError catch (e) {
      // on offlined entries page load using local offlined entries db
      if (activePage is OfflinedPage) {
        final data = await offlinedEntriesDB.loadEntries(page, params: params);
        _handleLoadEntriesResponse(page, data);
      }
      // if there's no internet check cache
      else if (e.noInternet!) {
        final cachedResponse = await entryCache.getResponse(params);
        if (cachedResponse != null) {
          _handleRawLoadedEntriesResponse(page, cachedResponse);
        }
      }
      // otherwise show error message
      else if (!e.isCancel!) {
        lastBackendError = e;
        isLoadingFromBackend = false;
        cancelToken = null;
        notifyListeners();
      }
    }
  }

  void _handleRawLoadedEntriesResponse(int page, String? response) {
    dynamic decoded;
    try {
      decoded = json.decode(response!);
    } catch (e) {}
    _handleLoadEntriesResponse(page, decoded);
  }

  void _handleLoadEntriesResponse(int page, dynamic response) {
    pagination =
    response == null ? Pagination.empty() : Pagination.fromJson(response);
    Iterable data = response == null ? [] : response['data'];

    entries = List.from(entries);
    data.forEach((v) {
      final fileEntry = FileEntry.fromJson(v);
      entryCache.set(fileEntry.id, fileEntry);
      entries.add(fileEntry.id);
    });

    lastBackendError = null;
    isLoadingFromBackend = false;
    notifyListeners();
  }

  _bindToScrollController() {
    scrollController.addListener(() {
      var threshold = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse &&
          scrollController.position.pixels > threshold &&
          !isLoadingFromBackend &&
          lastBackendError == null &&
          pagination.currentPage! < pagination.lastPage!) {
        loadEntries(pagination.currentPage! + 1);
      }
    });
  }
}

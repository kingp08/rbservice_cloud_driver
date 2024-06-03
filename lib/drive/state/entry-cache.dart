import 'dart:convert';
import 'package:bedrive/auth/user.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:crypto/crypto.dart';

class EntryCache {
  EntryCache(LocalStorage localStorage, this.currentUser) {
    storage = localStorage.temporary.scopedToUser(currentUser);
  }
  final Map<int?, FileEntry> _entries = {};
  get all {
    return _entries;
  }
  late LocalStorageAdapter storage;
  final User currentUser;

  FileEntry? get(int entryId) {
    return _entries[entryId];
  }

  FileEntry set(int? entryId, FileEntry entry) {
    return _entries[entryId] = entry;
  }

  cacheResponse(String response, Map<String, String?> params) {
    storage.put(_responseCacheKey(params), response);
  }

  Future<String?> getResponse(Map<String, String?> params) {
    return storage.get(_responseCacheKey(params));
  }

  String _responseCacheKey(Map<String, String?> params) {
    final string = params.toString().replaceAll(' ', '');
    final hash = md5.convert(utf8.encode(string)).toString();
    return hash;
  }
}
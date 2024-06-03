import 'dart:convert';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:bedrive/drive/state/file-entry/tag.dart';
import 'package:bedrive/utils/bool-to-int.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';

class FileEntry {
  FileEntry({
    required this.id,
    required this.name,
    this.description,
    this.fileName,
    this.mime,
    this.fileSize,
    this.parentId,
    this.password,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.path,
    this.diskPrefix,
    required this.type,
    this.extension,
    required this.public,
    this.thumbnail,
    this.workspaceId,
    required this.hash,
    this.url,
    this.users,
    this.tags,
    this.permissions,
    this.downloadFingerprint,
  });

  int id;
  String name;
  String? description;
  String? fileName;
  String? mime;
  int? fileSize;
  int? parentId;
  String? password;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  String path;
  String? diskPrefix;
  String type;
  String? extension;
  bool public;
  bool? thumbnail;
  int? workspaceId;
  String hash;
  String? url;
  List<FileEntryUser>? users;
  List<Tag>? tags;
  List<EntryPermission>? permissions;
  String? downloadFingerprint;

  factory FileEntry.fromRawJson(String str) => FileEntry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileEntry.fromJson(Map<String, dynamic> e) {
    final public = e["public"];
    final thumbnail = e["thumbnail"];
    final users = e['users'] is String ? json.decode(e["users"]) : e['users'];
    final tags = e['tags'] is String ? json.decode(e["tags"]) : e['tags'];
    final permissions = e['permissions'] is String ? json.decode(e["permissions"]) : e['permissions'];

    return FileEntry(
      id: e["id"],
      name: e["name"],
      description: e["description"],
      fileName: e["file_name"],
      mime: e["mime"],
      fileSize: e["file_size"],
      parentId: e["parent_id"],
      password: e["password"],
      createdAt: DateTime.parse(e["created_at"]),
      updatedAt: DateTime.parse(e["updated_at"]),
      deletedAt: e["deleted_at"] == null ? null : DateTime.parse(e["deleted_at"]),
      path: e["path"],
      diskPrefix: e["disk_prefix"],
      type: e["type"],
      extension: e["extension"],
      public: toBool(public),
      thumbnail: thumbnail is int ? toBool(thumbnail) : thumbnail,
      workspaceId: e["workspace_id"],
      hash: e["hash"],
      url: e["url"],
      users: List<FileEntryUser>.from((users ?? []).map((x) => FileEntryUser.fromJson(x))),
      tags: List<Tag>.from((tags ?? []).map((x) => Tag.fromJson(x))),
      permissions:  _buildPermissionList(permissions),
      downloadFingerprint: e["download_fingerprint"],
    );
  }

  Map<String, dynamic> toJson({bool forLocalSql = false, FileEntriesApi? api}) => {
    "id": id,
    "name": name,
    "description": description,
    "file_name": fileName,
    "mime": mime,
    "file_size": fileSize,
    "parent_id": parentId,
    "password": password,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "path": path,
    "disk_prefix": diskPrefix,
    "type": type,
    "extension": extension,
    "public": forLocalSql ? boolToInt(public) : public,
    "thumbnail": forLocalSql ? boolToInt(thumbnail ?? 0 as bool) : public,
    "workspace_id": workspaceId,
    "hash": hash,
    "url": api != null ? api.previewUrl(this) : url,
    "users": forLocalSql ? json.encode(users!.map((e) => e.toJson()).toList()) : users!.map((e) => e.toJson()).toList(),
    "tags": forLocalSql ? json.encode(tags!.map((e) => e.toJson()).toList()) : tags!.map((e) => e.toJson()).toList(),
    "download_fingerprint": downloadFingerprint,
    "permissions": json.encode(Map.fromIterable(
      permissions!.map((x) => 'files.${x.value}').toList(),
      value: (_) => true,
    )),
  };

  addToStarred() {
    if ( ! isStarred()) {
      tags!.add(Tag(id: 1, name: 'starred'));
    }
  }

  removeFromStarred() {
    if (isStarred()) {
      tags!.removeWhere((t) => t.name == 'starred');
    }
  }

  isStarred() {
    return tags!.firstWhereOrNull((t) => t.name == 'starred') != null;
  }
}

List<EntryPermission> _buildPermissionList(dynamic permissions) {
  if (permissions == null) {
    return [];
  } else {
    return (permissions as Map<String, dynamic>).entries.takeWhile((e) => e.value)
        .map((p) {
      switch(p.key) {
        case 'files.download':
          return EntryPermission.download;
        case 'files.update':
          return EntryPermission.update;
        case 'files.delete':
          return EntryPermission.delete;
        default:
          return EntryPermission.update;
      }
    }).toList();
  }
}

enum EntryPermission {
  download,
  update,
  delete,
}

extension EntryPermissionExtension on EntryPermission {
  get value => describeEnum(this);
}

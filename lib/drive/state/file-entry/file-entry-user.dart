import 'dart:convert';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';

class FileEntryUser {
  FileEntryUser({
    this.email,
    this.id,
    this.avatar,
    this.ownsEntry,
    this.entryPermissions,
    this.displayName,
  });

  String? email;
  int? id;
  String? avatar;
  bool? ownsEntry;
  SharedEntryPermissions? entryPermissions;
  String? displayName;

  factory FileEntryUser.fromRawJson(String str) => FileEntryUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileEntryUser.fromJson(Map<String, dynamic> json) => FileEntryUser(
    email: json["email"],
    id: json["id"],
    avatar: json["avatar"],
    ownsEntry: json["owns_entry"],
    // backend will return empty array [] if user has no permissions
    entryPermissions: SharedEntryPermissions.fromJson(json["entry_permissions"] is Map ? json["entry_permissions"] : {}),
    displayName: json["display_name"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "id": id,
    "avatar": avatar,
    "owns_entry": ownsEntry,
    "entry_permissions": entryPermissions!.toJson(),
    "display_name": displayName,
  };
}
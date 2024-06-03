import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';

class ShareePayload {
  final int? id;
  final SharedEntryPermissions permissions;
  final bool removed;

  ShareePayload(this.id, this.permissions, [this.removed = false]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "permissions": permissions,
    "removed": removed,
  };
}
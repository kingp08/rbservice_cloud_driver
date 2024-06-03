import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';

EntryPermissionName getPrimaryPermission(SharedEntryPermissions permissions) {
  if (permissions.edit == true) {
    return EntryPermissionName.edit;
  } else if (permissions.download == true) {
    return EntryPermissionName.download;
  } else {
    return EntryPermissionName.view;
  }
}
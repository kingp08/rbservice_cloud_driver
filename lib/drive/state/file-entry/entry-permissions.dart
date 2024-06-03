import 'dart:convert';

enum EntryPermissionName {
  edit,
  view,
  download
}

class SharedEntryPermissions {
  static Map<EntryPermissionName, String> displayNames = {
    EntryPermissionName.edit: 'Can edit',
    EntryPermissionName.view: 'Can view',
    EntryPermissionName.download: 'Can download',
  };

  SharedEntryPermissions({
    this.edit = false,
    this.view = true,
    this.download = false,
  }) {
    if (this.edit) {
      this.view = true;
      this.download = true;
    }
  }

  bool edit;
  bool view;
  bool download;

  static SharedEntryPermissions fromName(EntryPermissionName name) {
    if (name == EntryPermissionName.edit) {
      return SharedEntryPermissions(edit: true);
    } else if (name == EntryPermissionName.download) {
      return SharedEntryPermissions(download: true);
    } else {
      return SharedEntryPermissions();
    }
  }

  factory SharedEntryPermissions.fromRawJson(String str) => SharedEntryPermissions.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SharedEntryPermissions.fromJson(Map<String, dynamic> json) => SharedEntryPermissions(
    edit: json["edit"] ?? false,
    view: json["view"] ?? false,
    download: json["download"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "edit": edit,
    "view": view,
    "download": download,
  };
}

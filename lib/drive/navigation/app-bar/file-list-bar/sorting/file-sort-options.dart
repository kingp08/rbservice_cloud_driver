import 'package:flutter/foundation.dart';

enum EntrySortColumn {
  fileSize,
  name,
  updatedAt,
  createdAt,
  type,
  extension,
}

enum EntrySortDirection {
  desc,
  asc,
}

extension EntrySortColumnExtension on EntrySortColumn {
  String get value => describeEnum(this);
  String get displayName {
    switch(this) {
      case EntrySortColumn.fileSize:
        return 'Size';
      case EntrySortColumn.name:
        return 'Name';
      case EntrySortColumn.updatedAt:
        return 'Last Modified';
      case EntrySortColumn.createdAt:
        return 'Upload Date';
      case EntrySortColumn.type:
        return 'Type';
      case EntrySortColumn.extension:
        return 'Extension';
      default:
        return 'Default';
    }
  }
}

extension EntrySortDirectionExtension on EntrySortDirection {
  String get value => describeEnum(this);
  String get displayName {
    switch(this) {
      case EntrySortDirection.desc:
        return 'Descending';
      case EntrySortDirection.asc:
        return 'Ascending';
      default:
        return 'Default';
    }
  }
}
import 'package:flutter/foundation.dart';

enum FileListMode {
  list,
  grid
}

extension FileListModeExtension on FileListMode {
  String get value => describeEnum(this);
  FileListMode fromValue(String? value) {
    if (value == FileListMode.grid.value) {
      return FileListMode.grid;
    } else {
      return FileListMode.list;
    }
  }
}
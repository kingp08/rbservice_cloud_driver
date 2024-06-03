import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class FileViewTileName extends StatelessWidget {
  const FileViewTileName(
    this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry? fileEntry;

  @override
  Widget build(BuildContext context) {
    // file entry name might change
    final name = context.select((DriveState state) {
      return state.entryCache.get(fileEntry!.id)!.name;
    });

    return text(name);
  }
}

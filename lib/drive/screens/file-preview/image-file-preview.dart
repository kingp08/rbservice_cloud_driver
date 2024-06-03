import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class ImageFilePreview extends StatelessWidget {
  const ImageFilePreview(this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry fileEntry;

  @override
  Widget build(BuildContext context) {
    final api = context.select((DriveState s) => s.api);
    return Center(
      child: Container(
        color: Theme.of(context).canvasColor,
        child: getImageFileThumbnail(fileEntry, context, api: api),
      ),
    );
  }
}

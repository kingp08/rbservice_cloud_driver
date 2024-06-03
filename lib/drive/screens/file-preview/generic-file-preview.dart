import 'package:flutter/material.dart';
import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';

class GenericFilePreview extends StatelessWidget {
  const GenericFilePreview(
      this.fileEntry, {
        Key? key,
      }) : super(key: key);

  final FileEntry fileEntry;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FileThumbnail(fileEntry, size: FileThumbnailSize.small),
                    SizedBox(width: 5),
                    text(fileEntry.name, translate: false),
                  ],
                ),
                SizedBox(height: 10),
                text('File preview not available.'),
              ],
            ),
          ),
        ));
  }
}

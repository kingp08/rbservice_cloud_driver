import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class LoadingFileDialog extends StatelessWidget {
  LoadingFileDialog(this.fileEntry, this.downloadStream, {Key? key}) : super(key: key);
  final FileEntry fileEntry;
  final Stream downloadStream;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        getFileTypeImage(fileEntry.type, sizeInPixels: 38),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(fileEntry.name, translate: false, size: 18),
              SizedBox(height: 8),
              _Progress(fileEntry, downloadStream),
            ],
          ),
        )
      ]
    );
  }
}


class _Progress extends StatelessWidget {
  _Progress(this.fileEntry, this.downloadStream, {Key? key}) : super(key: key);
  final FileEntry fileEntry;
  final Stream downloadStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: downloadStream as Stream<int>?,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final bytesUploaded = snapshot.data ?? 0;
        final percentageUploaded = (bytesUploaded / fileEntry.fileSize! * 100).floor();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: percentageUploaded / 100),
            SizedBox(height: 8),
            text(':current of :total (:percentage%) loaded', size: 13, replacements: {
              'current': filesize(bytesUploaded),
              'total': filesize(fileEntry.fileSize),
              'percentage': percentageUploaded.toString(),
            }),
          ],
        );
      }
    );
  }
}

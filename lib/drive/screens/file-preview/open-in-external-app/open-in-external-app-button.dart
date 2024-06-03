import 'dart:io';

import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class OpenInExternalAppButton extends StatelessWidget {
  const OpenInExternalAppButton(this.fileEntry, {Key? key}) : super(key: key);
  final FileEntry fileEntry;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(Icons.open_in_new_outlined), onPressed: () async  {
      _tryToOpenFileWithExternalApp(context);
    });
  }

  _tryToOpenFileWithExternalApp(BuildContext context) async {
    final state = context.read<FilePreviewState>();
    final localFile = await state.getLocallyStoredFile(context, download: true);
    _openFileWithExternalApp(localFile, context);
  }

  _openFileWithExternalApp(File? localFile, BuildContext context) async {
    if (localFile != null) {
      OpenResult? result;
      try {
        result = await OpenFile.open(localFile.path, type: fileEntry.mime);
      } catch (e) {
        //
      }
      if (result == null || result.type != ResultType.done) {
        showSnackBar(trans('No installed application can open this file.'), context);
      }
    }
  }
}
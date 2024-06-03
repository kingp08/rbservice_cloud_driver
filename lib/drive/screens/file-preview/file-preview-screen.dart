import 'package:bedrive/drive/context-actions/show-drive-context-actions.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/screens/file-preview/generic-file-preview.dart';
import 'package:bedrive/drive/screens/file-preview/image-file-preview.dart';
import 'package:bedrive/drive/screens/file-preview/office-file-preview.dart';
import 'package:bedrive/drive/screens/file-preview/open-in-external-app/open-in-external-app-button.dart';
import 'package:bedrive/drive/screens/file-preview/pdf-file-preview.dart';
import 'package:bedrive/drive/screens/file-preview/text-file-preview.dart';
import 'package:bedrive/drive/screens/file-preview/video-file-preview.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilePreviewPageArgs {
  FilePreviewPageArgs(this.fileEntry);
  final FileEntry? fileEntry;
}

class FilePreviewScreen extends StatelessWidget {
  static const ROUTE = 'filePreview';

  static open(FileEntry? entry) {
    rootNavigatorKey.currentState!.pushNamed(
        FilePreviewScreen.ROUTE,
        arguments: FilePreviewPageArgs(entry)
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileEntry = _setFileEntry(context)!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: text(fileEntry.name, translate: false),
          actions: [
            OpenInExternalAppButton(fileEntry),
            MoreOptionsButton(fileEntry),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: _getFilePreviewWidget(fileEntry),
        )
    );
  }

  Widget _getFilePreviewWidget(FileEntry fileEntry) {
    if (fileEntry.type == 'video' || fileEntry.type == 'audio') {
      return VideoFilePreview(fileEntry);
    } else if (fileEntry.type == 'image') {
      return ImageFilePreview(fileEntry);
    } else if (fileEntry.type == 'pdf') {
      return PdfFilePreview(fileEntry);
    } else if (['spreadsheet', 'powerPoint', 'word'].contains(fileEntry.type)) {
      return OfficeFilePreview(fileEntry);
    } else if (fileEntry.type == 'text' && fileEntry.mime != 'text/rtf') {
      return TextFilePreview(fileEntry);
    } else {
      return GenericFilePreview(fileEntry);
    }
  }

  FileEntry? _setFileEntry(BuildContext context) {
    final fileEntry = (ModalRoute.of(context)!.settings.arguments as FilePreviewPageArgs).fileEntry;
    context.watch<FilePreviewState>().fileEntry = fileEntry;
    return fileEntry;
  }
}

class MoreOptionsButton extends StatelessWidget {
  const MoreOptionsButton(this.fileEntry, {Key? key}) : super(key: key);
  final FileEntry fileEntry;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(Icons.more_vert_outlined), onPressed: () async  {
      await showDriveContextActions(
        [fileEntry],
        context: context,
        hidePreview: true,
      );
    });
  }
}



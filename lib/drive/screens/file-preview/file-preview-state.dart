import 'dart:async';
import 'dart:io';
import 'package:bedrive/drive/dialogs/loading-dialog.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/screens/file-preview/open-in-external-app/loading-file-dialog.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:bedrive/utils/text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FilePreviewState with ChangeNotifier {
  static const DOWNLOAD_PATH = 'open-in-external-cache';
  FilePreviewState(
      this.offlinedEntries,
      this.localStorage,
      this.api,
      ) {
    downloadLocation =
        localStorage.temporary.scopedToSubDir(FilePreviewState.DOWNLOAD_PATH);
  }

  final OfflinedEntries offlinedEntries;
  final LocalStorage localStorage;
  final FileEntriesApi api;
  late LocalStorageAdapter downloadLocation;
  FileEntry? fileEntry;

  Future<File?> getLocallyStoredFile(BuildContext context,
      {FileEntry? entry, bool download = false}) async {
    entry = entry ?? this.fileEntry;
    File locallyStoredEntry = _getDownloadLocation(entry!);
    if (offlinedEntries.isFullyDownloaded(entry)) {
      return File(offlinedEntries.getPath(entry));
    } else if (locallyStoredEntry.existsSync()) {
      return locallyStoredEntry;
    } else if (download) {
      await _downloadFileLocally(context, entry);
      if (locallyStoredEntry.lengthSync() == entry.fileSize) {
        return locallyStoredEntry;
      }
    }
    return null;
  }

  _downloadFileLocally(BuildContext context, FileEntry entry) async {
    final downloadStreamCtrl = StreamController<int>.broadcast();
    final cancelToken = CancelToken();
    bool dialogOpen = true;

    // show loading dialog, if it's closed before download completes, cancel download
    LoadingDialog.show(
        child: LoadingFileDialog(entry, downloadStreamCtrl.stream),
        dismissible: true)
        .then((_) {
      dialogOpen = false;
      if (!downloadStreamCtrl.isClosed) {
        cancelToken.cancel();
        downloadStreamCtrl.close();
      }
    });

    // init file download
    try {
      await _downloadFile(cancelToken, entry, (bytesReceived, _) {
        downloadStreamCtrl.add(bytesReceived);
      });
    } on BackendError catch (e) {
      if (!e.isCancel!) {
        showSnackBar(trans('Could not download file, try again'), context);
      }
    }
    downloadStreamCtrl.close();
    if (dialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => LoadingDialog.hide());
    }
  }

  Future<File> _downloadFile(CancelToken cancelToken, FileEntry entry,
      ProgressCallback callback) async {
    final locallyStoredEntry = _getDownloadLocation(entry);
    final client = new Dio();
    await client.download(api.downloadUrl([entry]), locallyStoredEntry.path,
        cancelToken: cancelToken, onReceiveProgress: callback);
    return locallyStoredEntry;
  }

  File _getDownloadLocation(FileEntry entry) {
    return File(
        '${downloadLocation.rootDir.path}/${basenameWithoutExtension(entry.name)}.${entry.extension}');
  }
}

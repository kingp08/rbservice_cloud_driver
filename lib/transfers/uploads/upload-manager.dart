import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/notifications/notifications.dart';
import 'package:bedrive/transfers/transfer-queue/upload-transfer.dart';
import 'package:bedrive/transfers/uploads/file-upload.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

typedef UploadManagerCallback<T> = void Function(UploadTaskStatus? status,
    int? progress, String? taskId, FileEntry? fileEntry, BackendError? err);

FlutterUploader _uploader = FlutterUploader();

@pragma('vm:entry-point')
backgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterUploader uploader = FlutterUploader();
  uploader.clearUploads();
  uploader.progress.listen((e) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('uploader_send_port');
    try {
      send?.send([e.taskId, e.status.value, e.progress, null]);
    } catch (_) {}
  });
  uploader.result.listen((e) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('uploader_send_port');
    try {
      send?.send([e.taskId, e.status?.value, 100, e.response]);
    } catch (_) {}
  });
}

class UploadManager {
  UploadManager(this.api, this.notifications) {
    _bindBackgroundIsolate();
    _uploader.setBackgroundHandler(backgroundHandler);
  }

  final FileEntriesApi api;
  final Notifications notifications;

  bool initialized = false;
  ReceivePort _port = ReceivePort();
  bool debug = true;

  final Map<String?, UploadManagerCallback?> _callbacks = {};

  Future<String> enqueue(FileUpload upload,
      {UploadManagerCallback? callback}) async {
    final uploadId = await _uploader.enqueue(MultipartFormDataUpload(
        url: '${api.http!.backendApiUrl}/uploads',
        headers: api.http!.authHeaders,
        files: [
          FileItem(
            path: upload.file.path,
          )
        ],
        data: {
          'parentId': upload.parentId ?? ''
        }));

    if (callback != null) {
      registerCallback(uploadId, callback);
    }

    return uploadId;
  }

  pause(UploadTransfer transfer) {
    cancel(transfer);
  }

  Future<String> resume(UploadTransfer transfer) async {
    return this.restart(transfer);
  }

  Future<String> restart(UploadTransfer transfer) async {
    final oldTaskId = transfer.taskId;
    final newTaskId = await enqueue(transfer.fileUpload);
    _callbacks[newTaskId] = _callbacks[oldTaskId];
    _callbacks.remove(oldTaskId);
    return newTaskId;
  }

  cancel(UploadTransfer transfer) {
    _uploader.cancel(taskId: transfer.taskId!);
  }

  registerCallback(String? taskId, UploadManagerCallback callback) {
    _callbacks[taskId] = callback;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'uploader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? taskId = data[0];
      UploadTaskStatus? status =
          data[1] != null ? UploadTaskStatus.from(data[1]) : null;
      int? progress = data[2];
      String? responseString = data[3];
      UploadManagerCallback? callback = _callbacks[taskId];

      if (callback != null) {
        Map<String, dynamic>? response;
        try {
          response = responseString != null ? json.decode(responseString) : {};
        } catch (_) {
          response = {};
        }

        final fileEntry = response!["fileEntry"] == null
            ? null
            : FileEntry.fromJson(response["fileEntry"]);
        final err = status == UploadTaskStatus.failed
            ? BackendError(errResponse: response)
            : null;

        if (err != null &&
            responseString != null &&
            response['message'] == null &&
            responseString.contains('413')) {
          err.message = trans('Upload failed. File size is too big.');
        }

        callback(status, progress, taskId, fileEntry, err);
        if (status == UploadTaskStatus.complete && fileEntry != null) {
          _callbacks.remove(taskId);
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('uploader_send_port');
  }
}

import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/notifications/notifications.dart';
import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';

typedef DownloadManagerCallback<T> = void Function(
    DownloadTaskStatus? status, int progress, String? taskId);

class DownloadManager {
  DownloadManager(this.api, this.notifications) {
    FlutterDownloader.initialize(
      debug: false,
    ).then((_) {
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
    });
  }
  final FileEntriesApi api;
  final Notifications notifications;

  bool initialized = false;
  ReceivePort _port = ReceivePort();
  bool debug = true;

  final Map<String?, DownloadManagerCallback?> _callbacks = {};
  final Map<String?, int> _progressCounts = {};

  Future<String?> enqueue(FileEntry entry, String destination,
      {DownloadManagerCallback? callback}) async {
    final taskId = await FlutterDownloader.enqueue(
      url: api.downloadUrl([entry]),
      fileName: basename(destination),
      savedDir: dirname(destination),
      showNotification: false,
      openFileFromNotification: false,
    );

    if (callback != null) {
      registerCallback(taskId, callback);
    }

    return taskId;
  }

  pause(FileTransfer transfer) {
    FlutterDownloader.pause(taskId: transfer.taskId!);
  }

  Future<String?> resume(FileTransfer transfer) async {
    final oldTaskId = transfer.taskId!;
    final newTaskId = await FlutterDownloader.resume(taskId: oldTaskId);
    _callbacks[newTaskId] = _callbacks[oldTaskId];
    _callbacks.remove(oldTaskId);
    return newTaskId;
  }

  Future<String?> restart(FileTransfer transfer) async {
    final oldTaskId = transfer.taskId;
    final oldTask = (await FlutterDownloader.loadTasks())!
        .firstWhere((t) => t.taskId == oldTaskId);
    final destination = oldTask.savedDir + '/' + oldTask.filename!;
    final newTaskId = await enqueue(transfer.fileEntry!, destination);
    _callbacks[newTaskId] = _callbacks[oldTaskId];
    _callbacks.remove(oldTaskId);
    return newTaskId;
  }

  cancel(FileTransfer transfer) {
    final taskId = transfer.taskId;
    if (taskId != null) {
      FlutterDownloader.cancel(taskId: taskId);
    }
  }

  registerCallback(String? taskId, DownloadManagerCallback callback) {
    _callbacks[taskId] = callback;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? taskId = data[0];
      DownloadTaskStatus? status = DownloadTaskStatus(data[1]);
      int progress = data[2] <= 0 ? 0 : data[2];
      final callback = _callbacks[taskId];

      final oldCount = _progressCounts[taskId];
      _progressCounts[taskId] = oldCount == null ? 0 : oldCount + 1;

      // TODO: remove after this is merged: https://github.com/fluttercommunity/flutter_downloader/pull/371
      if (progress > 100) {
        progress = min((_progressCounts[taskId]! * 10), 90);
      }

      if (callback != null) {
        callback(status, progress, taskId);
        if (status == DownloadTaskStatus.complete) {
          _callbacks.remove(taskId);
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
}

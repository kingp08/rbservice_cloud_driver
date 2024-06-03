import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/notifications/notification-id.dart';
import 'package:bedrive/notifications/notifications.dart';
import 'package:bedrive/transfers/downloads/download-manager.dart';
import 'package:bedrive/transfers/transfer-queue/download-transfer.dart';
import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/transfer-queue/upload-transfer.dart';
import 'package:bedrive/transfers/uploads/file-upload.dart';
import 'package:bedrive/transfers/uploads/upload-manager.dart';
import 'package:bedrive/transfers/uploads/upload-progress.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:bedrive/utils/text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

class TransferQueue with ChangeNotifier {
  static const notifIds = {
    FileTransferType.download: 59658458,
    FileTransferType.upload: 19648471,
    FileTransferType.offline: 193148874,
  };
  static const fileName = 'transfer-queue.json';
  final Notifications notifications;
  final DownloadManager downloader;
  final UploadManager uploader;
  final LocalStorage localStorage;

  _LastProgressUpdate _lastProgressUpdate = _LastProgressUpdate();
  late StreamController<FileEntry> _uploadCompletedCtrl;
  Map<String, FileTransfer> queue = {};

  Stream<FileEntry> get uploadCompleted {
    return _uploadCompletedCtrl.stream;
  }

  TransferQueue(
      this.notifications, this.downloader, this.uploader, this.localStorage) {
    _restoreQueue();
    _uploadCompletedCtrl = StreamController<FileEntry>.broadcast();
  }

  addUpload(FileUpload fileUpload) async {
    if (fileUpload.fingerprint == null) {
      return;
    }
    final callback = _createUploadCallback(fileUpload.fingerprint!);
    final uploadId = await uploader.enqueue(fileUpload, callback: callback);
    queue = {
      ...queue,
      fileUpload.fingerprint!: UploadTransfer(fileUpload, uploadId),
    };
    _updateNotification(FileTransferType.upload);
    notifyListeners();
    _persistQueue();
  }

  Future<String?> addDownload(FileEntry fileEntry, String destination,
      {FileTransferType type = FileTransferType.download}) async {
    final fingerprint = base64Encode(utf8.encode(destination));
    final callback = _createDownloadCallback(fingerprint, fileEntry);
    final taskId =
        await downloader.enqueue(fileEntry, destination, callback: callback);
    if (taskId != null) {
      queue = {
        ...queue,
        fingerprint:
            DownloadTransfer(fileEntry, fingerprint, taskId, type: type),
      };
      _updateNotification(type);
      notifyListeners();
      _persistQueue();
      return fingerprint;
    }
    return null;
  }

  updateProgress(String fingerprint, TransferProgress progress) {
    final transfer = queue[fingerprint];
    if (_lastProgressUpdate.progress != progress && transfer != null) {
      final now = DateTime.now();
      // update on first, last and then throttle to one update every 350ms
      if (_lastProgressUpdate.time == null ||
          progress.percentage == 100 ||
          now.difference(_lastProgressUpdate.time!).inMilliseconds > 350) {
        queue[fingerprint]?.progress = progress;
        _updateNotification(transfer.type);
        _lastProgressUpdate.set(now, progress);
        notifyListeners();
      }
    }
  }

  cancelTransfer(String? fingerprint) {
    final transfer = queue[fingerprint];
    if (transfer != null) {
      final newQueue = {...queue};
      transfer is UploadTransfer
          ? uploader.cancel(transfer)
          : downloader.cancel(transfer);
      newQueue.remove(fingerprint);
      queue = newQueue;
      _updateNotification(transfer.type);
      notifyListeners();
      _persistQueue();
    }
  }

  pauseTransfer(String? fingerprint) {
    final transfer = queue[fingerprint];
    if (transfer != null) {
      transfer.status = TransferQueueStatus.paused;
      transfer is UploadTransfer
          ? uploader.pause(transfer)
          : downloader.pause(transfer);
      _updateNotification(transfer.type);
      notifyListeners();
      _persistQueue();
    }
  }

  resumeTransfer(String? fingerprint, {bool? restart}) async {
    final transfer = queue[fingerprint];
    Future<String?> newTaskId;
    if (transfer != null) {
      transfer.status = TransferQueueStatus.inProgress;
      if (restart == true) {
        newTaskId = transfer is UploadTransfer
            ? uploader.restart(transfer)
            : downloader.restart(transfer);
      } else {
        newTaskId = transfer is UploadTransfer
            ? uploader.resume(transfer)
            : downloader.resume(transfer);
      }
      transfer.taskId = await newTaskId;
      _updateNotification(transfer.type);
      notifyListeners();
      _persistQueue();
    }
  }

  completeTransfer(String? fingerPrint, FileEntry? fileEntry) {
    final transfer = queue[fingerPrint];
    if (transfer != null && transfer.status != TransferQueueStatus.completed) {
      transfer.status = TransferQueueStatus.completed;
      transfer.fileEntry = fileEntry;
      if (transfer is UploadTransfer && fileEntry != null) {
        _uploadCompletedCtrl.add(fileEntry);
      }
      _updateNotification(transfer.type);
      notifyListeners();
      _persistQueue();
    }
  }

  clearCompleted() {
    final newQueue = {...queue};
    newQueue.removeWhere((_, t) => t.status == TransferQueueStatus.completed);
    queue = newQueue;
    FileTransferType.values.forEach((e) {
      _updateNotification(e);
    });
    notifyListeners();
    _persistQueue();
  }

  errorTransfer(String? fingerprint, BackendError? error) {
    final transfer = queue[fingerprint]!;
    transfer is UploadTransfer
        ? uploader.pause(transfer)
        : downloader.pause(transfer);
    transfer.status = TransferQueueStatus.error;
    transfer.backendError = error;
    _updateNotification(transfer.type);
    notifyListeners();
    _persistQueue();
  }

  @override
  void dispose() {
    _uploadCompletedCtrl.close();
    super.dispose();
  }

  _persistQueue() {
    final encoded = json.encode(queue);
    localStorage.permanent.put(TransferQueue.fileName, encoded);
  }

  _restoreQueue() async {
    if (await localStorage.permanent.exists(fileName)) {
      Map<String, dynamic> decoded =
          json.decode(await (localStorage.permanent.get(fileName)) ?? '');
      decoded.forEach((fingerprint, decodedTransfer) {
        if (decodedTransfer['type'] == describeEnum(FileTransferType.upload)) {
          final transfer = UploadTransfer.fromJson(decodedTransfer);
          if (transfer.fileUpload.file.existsSync()) {
            queue[fingerprint] = transfer;
            if (transfer.status != TransferQueueStatus.completed) {
              final callback = _createUploadCallback(fingerprint);
              uploader.registerCallback(transfer.taskId, callback);
            }
          }
        } else {
          final transfer =
              DownloadTransfer.fromJson(decodedTransfer, downloader);
          queue[fingerprint] = transfer;
          if (transfer.status != TransferQueueStatus.completed) {
            final callback =
                _createDownloadCallback(fingerprint, transfer.fileEntry);
            downloader.registerCallback(transfer.taskId, callback);
          }
        }
      });
      FileTransferType.values.forEach((e) {
        _updateNotification(e, hideIfAllCompleted: true);
      });
      notifyListeners();
    }
  }

  DownloadManagerCallback _createDownloadCallback(
      String fingerprint, FileEntry? fileEntry) {
    return (DownloadTaskStatus? status, int progress, _) {
      if (status == DownloadTaskStatus.complete) {
        completeTransfer(fingerprint, fileEntry);
      } else if (status == DownloadTaskStatus.running) {
        updateProgress(fingerprint,
            TransferProgress(queue[fingerprint]!.size!, percentage: progress));
      } else if (status == DownloadTaskStatus.failed) {
        errorTransfer(
            fingerprint, BackendError(message: 'File download failed'));
      }
    };
  }

  UploadManagerCallback _createUploadCallback(String fingerprint) {
    return (UploadTaskStatus? status, int? progress, String? taskId,
        FileEntry? fileEntry, BackendError? err) {
      if (status == UploadTaskStatus.complete) {
        completeTransfer(fingerprint, fileEntry);
      } else if (status == UploadTaskStatus.running) {
        updateProgress(fingerprint,
            TransferProgress(queue[fingerprint]!.size!, percentage: progress));
      } else if (status == UploadTaskStatus.failed) {
        errorTransfer(fingerprint, err);
      }
    };
  }

  _updateNotification(FileTransferType type,
      {bool hideIfAllCompleted = false}) {
    // TODO: make notifs translatable easier
    if (Platform.isIOS) return;
    final notifId = notifIds[type];
    List<FileTransfer> queue =
        this.queue.values.where((e) => e.type == type).toList();
    List<FileTransfer> pending =
        queue.where((e) => e.status != TransferQueueStatus.completed).toList();
    String payload =
        json.encode({'notifId': NotificationType.transferProgress});

    // if no transfers in queue, hide notif
    if (queue.length == 0 || (hideIfAllCompleted && pending.isEmpty)) {
      notifications.cancel(notifId!);
      return;
    }

    String action;
    if (type == FileTransferType.download) {
      action = 'download';
    } else if (type == FileTransferType.upload) {
      action = 'upload';
    } else {
      action = 'offlin';
    }

    // all completed
    if (pending.isEmpty) {
      final message = queue.length == 1
          ? trans('${action.capitalize()}ed ":name"', replacements: {'name': queue.first.displayName})
          : trans('${action.capitalize()}ed :count files', replacements: {'count': queue.length.toString()});
      notifications.notify(message, localId: notifId, payload: payload);
    }

    // all paused
    else if (pending.every((e) => e.status == TransferQueueStatus.paused)) {
      final message = pending.length == 1
          ? trans('${action.capitalize()}ing ":name"', replacements: {'name': pending.first.displayName})
          : trans('${action.capitalize()}ing :count files', replacements: {'count': pending.length.toString()});
      notifications.notify(message,
          body: 'Paused', progress: 0, localId: notifId, payload: payload);
    }

    // all errored
    else if (pending.every((e) => e.status == TransferQueueStatus.error)) {
      final errorAction = action == 'offlin' ? 'offline' : action;
      final message = pending.length == 1
          ? trans('Could not $errorAction ":name"', replacements: {'name': pending.first.displayName})
          : trans('Could not $errorAction :count files', replacements: {'count': pending.length.toString()});
      notifications.notify(message, localId: notifId, payload: payload);
    }

    // some are still in progress
    else {
      final message = pending.length == 1
          ? trans('${action.capitalize()}ing ":name"', replacements: {'name': pending.first.displayName})
          : trans('${action.capitalize()}ing :count files', replacements: {'count': pending.length.toString()});
      final body = filesize(pending.fold(
          0, (dynamic prev, curr) => prev + curr.progress!.bytesLeft));
      final progress = pending
          .fold(
              0,
              (dynamic prev, curr) =>
                  (prev + curr.progress!.percentage) / pending.length)
          .floor();
      notifications.notify(message,
          body: body, progress: progress, localId: notifId, payload: payload);
    }
  }
}

class _LastProgressUpdate {
  _LastProgressUpdate([this.time, this.progress]);
  DateTime? time;
  TransferProgress? progress;

  set(DateTime time, TransferProgress progress) {
    this.time = time;
    this.progress = progress;
  }
}

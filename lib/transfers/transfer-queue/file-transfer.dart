import 'dart:convert';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/transfers/uploads/upload-progress.dart';
import 'package:flutter/foundation.dart';

enum FileTransferType {
  upload,
  download,
  offline,
}

enum TransferQueueStatus {
  paused,
  inProgress,
  completed,
  error,
}

extension TransferQueueStatusValue on TransferQueueStatus {
  String get value => describeEnum(this);
  TransferQueueStatus fromValue(String? value) {
    if (value == TransferQueueStatus.paused.value) {
      return TransferQueueStatus.paused;
    } else if (value == TransferQueueStatus.completed.value) {
      return TransferQueueStatus.completed;
    } else if (value == TransferQueueStatus.error.value) {
      return TransferQueueStatus.error;
    } else {
      return TransferQueueStatus.inProgress;
    }
  }
}

abstract class FileTransfer {
  FileEntry? fileEntry;
  TransferProgress? progress;
  String? taskId;
  TransferQueueStatus? status;
  BackendError? backendError;
  String? get displayName;
  String? get fingerprint;
  int? get size;
  FileTransferType get type;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() {
    return {
      "fileEntry": fileEntry != null ? fileEntry!.toJson() : null,
      "progress": progress!.toJson(),
      "status": status!.value,
      "fingerprint": fingerprint,
      "taskId": taskId,
      "backednError": backendError != null ? backendError!.toJson() : null,
    };
  }
}
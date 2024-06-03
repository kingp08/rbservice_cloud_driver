import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/transfers/downloads/download-manager.dart';
import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/uploads/upload-progress.dart';
import 'package:flutter/foundation.dart';

class DownloadTransfer extends FileTransfer {
  DownloadTransfer(this.fileEntry, this.fingerprint, this.taskId, {this.status = TransferQueueStatus.inProgress, this.type = FileTransferType.download}) {
    progress = TransferProgress(fileEntry.fileSize!, percentage: 0);
  }

  final FileEntry fileEntry;
  final String? fingerprint;
  String? taskId;
  TransferQueueStatus? status;
  String? get displayName => fileEntry.name;
  int? get size => fileEntry.fileSize;
  FileTransferType type;

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['taskId'] = taskId;
    json['type'] = describeEnum(FileTransferType.download);
    return json;
  }

  factory DownloadTransfer.fromJson(Map<String, dynamic> e, DownloadManager downloadManager) {
    final transfer = DownloadTransfer(
      FileEntry.fromJson(e['fileEntry']),
      e['fingerprint'],
      e['taskId'],
      status: TransferQueueStatus.paused.fromValue(e['status']),
      type: e['type'] == 'offline' ? FileTransferType.offline : FileTransferType.download,
    );
    return transfer;
  }
}
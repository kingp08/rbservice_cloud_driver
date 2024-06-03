import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/uploads/file-upload.dart';
import 'package:bedrive/transfers/uploads/upload-progress.dart';
import 'package:flutter/foundation.dart';

class UploadTransfer extends FileTransfer {
  UploadTransfer(this.fileUpload, this.taskId, [this.status = TransferQueueStatus.inProgress]) {
    progress = TransferProgress(fileUpload.sizeBytes!, percentage: 0);
  }

  final FileUpload fileUpload;
  String? taskId;
  TransferQueueStatus? status;
  String? get displayName => fileUpload.name;
  String? get fingerprint => fileUpload.fingerprint;
  int? get size => fileUpload.sizeBytes;
  FileTransferType get type => FileTransferType.upload;

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['fileUpload'] = fileUpload.toJson();
    json['type'] = describeEnum(FileTransferType.upload);
    return json;
  }

  factory UploadTransfer.fromJson(Map<String, dynamic> e) {
    return UploadTransfer(
      FileUpload.fromJson(e['fileUpload']),
      e['taskId'],
      TransferQueueStatus.paused.fromValue(e['status']),
    );
  }
}
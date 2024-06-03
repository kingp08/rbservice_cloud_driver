import 'dart:convert';

class TransferProgress {
  int? percentage;
  int? bytesLeft;
  TransferProgress(int bytesToUpload, {int? percentage, int? bytesUploaded}) {
    if (percentage != null && bytesUploaded == null) {
      bytesUploaded = ((percentage / 100) * bytesToUpload).floor();
    }
    if (percentage == null && bytesUploaded != null) {
      percentage = (100 * bytesUploaded / bytesToUpload).floor();
    }
    this.percentage = percentage ?? 0;
    this.bytesLeft = bytesToUpload - (bytesUploaded ?? 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TransferProgress &&
              runtimeType == other.runtimeType &&
              percentage == other.percentage &&
              bytesLeft == other.bytesLeft;

  @override
  int get hashCode => percentage.hashCode ^ bytesLeft.hashCode;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "percentage": percentage,
    "bytesLeft": bytesLeft,
  };
}
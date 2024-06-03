import 'dart:convert';

import 'package:filesize/filesize.dart';

class SpaceUsage {
  SpaceUsage({
    this.bytesUsed = 0,
    this.bytesAvailable = 0,
  }) {
    humanReadableUsed = filesize(bytesUsed);
    humanReadableAvailable = filesize(bytesAvailable);
    usedPercentage = bytesAvailable == 0 ? 0 : (bytesUsed! * 100) ~/ bytesAvailable!;
  }

  final int? bytesUsed;
  final int? bytesAvailable;
  late int usedPercentage;
  String? humanReadableUsed;
  String? humanReadableAvailable;

  factory SpaceUsage.fromRawJson(String str) => SpaceUsage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpaceUsage.fromJson(Map<String, dynamic> json) => SpaceUsage(
    bytesUsed: json["used"],
    bytesAvailable: json["available"],
  );

  Map<String, dynamic> toJson() => {
    "used": bytesUsed,
    "available": bytesAvailable,
  };
}
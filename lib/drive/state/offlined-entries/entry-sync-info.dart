import 'dart:convert';

class EntrySyncInfo {
  EntrySyncInfo({
    this.updatedAt,
    this.fileName,
  });

  final DateTime? updatedAt;
  final String? fileName;

  factory EntrySyncInfo.fromRawJson(String str) => EntrySyncInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EntrySyncInfo.fromJson(Map<String, dynamic> json) => EntrySyncInfo(
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    fileName: json["file_name"] == null ? null : json["file_name"],
  );

  Map<String, dynamic> toJson() => {
    "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
    "file_name": fileName == null ? null : fileName,
  };
}
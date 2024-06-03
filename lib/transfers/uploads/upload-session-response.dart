import 'dart:convert';

import 'package:bedrive/drive/state/file-entry/file-entry.dart';

class UploadSessionResponse {
  UploadSessionResponse({
    this.fileEntry,
    this.uploadedChunks = const [],
  });

  final FileEntry? fileEntry;
  final List<UploadedChunk> uploadedChunks;

  factory UploadSessionResponse.fromRawJson(String str) => UploadSessionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadSessionResponse.fromJson(Map<String, dynamic> json) => UploadSessionResponse(
    fileEntry: json["fileEntry"] == null ? null : FileEntry.fromJson(json["fileEntry"]),
    uploadedChunks: List<UploadedChunk>.from((json["uploadedChunks"] ?? []).map((x) => UploadedChunk.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "fileEntry": fileEntry,
    "uploadedChunks": List<dynamic>.from(uploadedChunks.map((x) => x.toJson())),
  };
}

class UploadedChunk {
  UploadedChunk({
    this.number,
    this.size = 0,
  });

  final int? number;
  final int size;

  factory UploadedChunk.fromRawJson(String str) => UploadedChunk.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadedChunk.fromJson(Map<String, dynamic> json) => UploadedChunk(
    number: json["number"].toInt(),
    size: json["size"].toInt(),
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "size": size,
  };
}

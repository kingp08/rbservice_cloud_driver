import 'dart:convert';

import 'package:flutter/foundation.dart';

class UploadHttpParams {
  UploadHttpParams({
    this.disk,
    this.diskPrefix,
    this.parentId,
    this.relativePath,
  });

  final Disk? disk;
  final String? diskPrefix;
  final String? parentId;
  final String? relativePath;

  Map<String, dynamic> toHttpPayload() => {
    "disk": disk == null ? null : disk!.value,
    "diskPrefix": diskPrefix == null ? null : diskPrefix,
    "parentId": parentId == null ? null : parentId,
    "relativePath": relativePath == null ? null : relativePath,
  };
}

class ChunkedUploadHeaders {
  ChunkedUploadHeaders({
    this.fingerprint,
    this.chunkCount,
    this.originalFileName,
    this.originalFileSize,
    this.metadata,
  });

  final int? chunkCount;
  final String? fingerprint;
  final String? originalFileName;
  final int? originalFileSize;
  final Map<String, dynamic>? metadata;

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    return metadata.entries.map((e) {
      final String value = e.value == null ? '' : e.value.toString();
      return e.key + ' ' + base64Encode(utf8.encode(value));
    }).join(',');
  }

  Map<String, dynamic> toMap({
    int? chunkIndex,
    int? chunkStart,
    int? chunkEnd,
  }) => {
    "Be-Fingerprint": fingerprint == null ? null : fingerprint,
    "Be-Chunk-Index": chunkIndex,
    "Be-Chunk-Count": chunkCount == null ? null : chunkCount,
    "Be-Chunk-Start": chunkStart,
    "Be-Chunk-End": chunkEnd,
    "Be-Original-Filename": originalFileName == null ? null : originalFileName,
    "Be-Original-Filesize": originalFileSize == null ? null : originalFileSize,
    "Be-Metadata": ChunkedUploadHeaders._encodeMetadata(metadata!),
  };
}

enum Disk { PRIVATE, PUBLIC }
extension DiskValue on Disk {
  String get value => describeEnum(this);
}
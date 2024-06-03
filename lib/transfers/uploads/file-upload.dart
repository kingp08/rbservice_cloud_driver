import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:slugify/slugify.dart';

class FileUpload {
  FileUpload(this.path, this.parentId) {
    file = File(path);
    name = basename(path);
    if (file.existsSync()) {
      _generateFingerprint();
    }
  }
  final String path;
  final String? parentId;
  String? name;
  late File file;
  String? fingerprint;
  int? _sizeBytes;
  int? get sizeBytes {
    if (_sizeBytes != null) {
      return _sizeBytes;
    } else {
      return _sizeBytes = file.existsSync() ? file.lengthSync() : 0;
    }
  }

  _generateFingerprint() {
    final fingerprintArray = <String?>[
      'be-upload',
      slugify(basename(file.path)),
      lookupMimeType(file.path),
      file.lengthSync().toString(),
      // file.lastModifiedSync().toString(), TODO: last_modified date changes after picking file
      //slugify(this.file.relativePath, '-', true),
    ].join('|');
    this.fingerprint = base64Encode(utf8.encode(fingerprintArray));
  }

  Map<String, dynamic> toJson() => {
    "path": path,
    "parentId": parentId,
  };

  factory FileUpload.fromJson(Map<String, dynamic> e) {
    return FileUpload(e['path'], e['parentId']);
  }
}
import 'dart:async';
import 'dart:math';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/transfers/transfer-queue/file-transfer.dart';
import 'package:bedrive/transfers/uploads/file-upload.dart';
import 'package:bedrive/transfers/uploads/upload-http-params.dart';
import 'package:bedrive/transfers/uploads/upload-progress.dart';
import 'package:bedrive/transfers/uploads/upload-session-response.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:dio/dio.dart';

class ChunkedUpload {
  final AppHttpClient httpClient;
  CancelToken? _cancelToken;
  final bool _shouldResumeUploads = true;
  final int _formDataBoundaryBytes = 166;
  final int _concurrentUploadLimit = 3;
  final int _maxChunkSize = 5242880;

  void Function(String? fingerprint, FileEntry? fileEntry) onComplete;
  void Function(String? fingerprint, TransferProgress progress) onProgress;
  void Function(String? fingerprint, BackendError error) onError;

  FileUpload? _fileUpload;
  late ChunkedUploadHeaders _uploadHeaders;

  late int _totalBytesToUpload;
  int _totalBytesUploaded = 0;
  int _chunkCount = 0;
  List<int> _chunkQueue = [];
  TransferQueueStatus status = TransferQueueStatus.inProgress;

  ChunkedUpload(this.httpClient, {
    required this.onProgress,
    required this.onError,
    required this.onComplete
  });

  start(FileUpload? fileUpload) async {
    this._fileUpload = fileUpload;
    final response = await _startSession();

    if (response.fileEntry != null) {
      _emitComplete(response.fileEntry);
    } else {
      for (int i = 0; i < _concurrentUploadLimit; i++) {
        _uploadNextChunk();
      }
    }
  }

  pause() {
    status = TransferQueueStatus.paused;
    if ( ! _cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
  }

  resume() {
    if (
      _fileUpload != null &&
      status != TransferQueueStatus.completed &&
      status != TransferQueueStatus.inProgress) {
        start(_fileUpload);
    }
  }

  _uploadNextChunk() async {
    if (_chunkQueue.isEmpty) return;

    final chunkIndex = _chunkQueue.first;
    _chunkQueue.remove(chunkIndex);
    final start = chunkIndex * _maxChunkSize;
    final end = min((chunkIndex + 1) * _maxChunkSize, _fileUpload!.sizeBytes!);
    final chunkStream = _fileUpload!.file.openRead(start, end);
    final formData = FormData.fromMap({
      'file': MultipartFile(chunkStream, end - start, filename: 'blob'),
    });

    try {
      final response = await _makeChunkHttpRequest(formData, chunkIndex, start, end);
      if (response.fileEntry != null) {
        _emitComplete(response.fileEntry);
      } else {
        _uploadNextChunk();
      }
    } on BackendError catch (e) {
      if ( ! e.isCancel!) {
        status = TransferQueueStatus.error;
        onError(_fileUpload!.fingerprint, e);
      }
    }
  }

  Future<UploadSessionResponse> _makeChunkHttpRequest(FormData formData, int chunkIndex, int start, int end) async {
    int lastChunkProgress = 0;
    final response = UploadSessionResponse.fromJson(
      await httpClient.post(
        '/uploads/sessions/chunks',
        payload: formData,
        cancelToken: this._cancelToken,
        options: Options(
          headers: _uploadHeaders.toMap(
            chunkIndex: chunkIndex,
            chunkStart: start,
            chunkEnd: end
          )
        ),
        onUploadProgress: (int chunkProgressBytes, int chunkTotalSize) {
          _totalBytesUploaded += (chunkProgressBytes - (lastChunkProgress));
          lastChunkProgress = chunkProgressBytes;
          onProgress(_fileUpload!.fingerprint, TransferProgress(_totalBytesToUpload, bytesUploaded: _totalBytesUploaded));
        }
      )
    );
    return response;
  }

  Future<UploadSessionResponse> _startSession() async {
    status = TransferQueueStatus.inProgress;
    _cancelToken = CancelToken();
    _chunkCount = (_fileUpload!.sizeBytes! / _maxChunkSize).ceil();
    _chunkQueue = [for(var i=0; i<_chunkCount; i++) i];
    _totalBytesToUpload = _fileUpload!.sizeBytes! + (_formDataBoundaryBytes * _chunkCount);
    _totalBytesUploaded = 0;
    _uploadHeaders = ChunkedUploadHeaders(
      fingerprint: _fileUpload!.fingerprint,
      chunkCount: _chunkCount,
      originalFileName: _fileUpload!.name,
      originalFileSize: _fileUpload!.sizeBytes,
      metadata: {
        'parentId': _fileUpload!.parentId,
      }
    );

    final response = await _loadExistingChunks();
    response.uploadedChunks.forEach((c) {
      _chunkQueue.remove(c.number);
      _totalBytesUploaded += (c.size + _formDataBoundaryBytes);
    });
    return response;
  }

  Future<UploadSessionResponse> _loadExistingChunks() async {
    if (_shouldResumeUploads) {
      try {
        return UploadSessionResponse.fromJson(
          await this.httpClient.post('/uploads/sessions/load', cancelToken: _cancelToken, options: Options(headers: _uploadHeaders.toMap())),
        );
      } on BackendError catch(_) {
        return UploadSessionResponse();
      }
    } else {
      return UploadSessionResponse();
    }
  }

  _emitComplete(FileEntry? fileEntry) {
    status = TransferQueueStatus.completed;
    onComplete(_fileUpload!.fingerprint, fileEntry);
  }
}
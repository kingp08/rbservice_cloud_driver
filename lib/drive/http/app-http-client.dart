import 'dart:io';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:dio/dio.dart';

typedef AppHttpClientErrorHandler = void Function(BackendError e);

class AppHttpClient {
  AppHttpClient(this.baseBackendUrl, String? apiVersion, {String? accessToken}) {
    this.backendApiUrl = '$baseBackendUrl/api/$apiVersion';
    _client = Dio();
    _client.options.baseUrl = backendApiUrl!;
    this.accessToken = accessToken;
    _client.options.headers = {
      HttpHeaders.contentTypeHeader : 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
  }
  late Dio _client;
  final String? baseBackendUrl;
  String? backendApiUrl;
  final List<AppHttpClientErrorHandler> errorHandlers = [];

  String? _accessToken;
  set accessToken(String? accessToken) {
    _accessToken = accessToken;
    if (accessToken != null) {
      _client.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }
  String? get accessToken {
    return _accessToken;
  }

  Map<String, String> get authHeaders {
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<T> get<T>(String uri, {Map<String, String?>? params, Options? options, CancelToken? cancelToken}) {
    return _client.get<T>(uri, queryParameters: params, options: options, cancelToken: cancelToken).catchError((e) => _handleError(e))
        .then((response) {
          return response.data!;
    });
  }

  Future<T> post<T>(String uri, {dynamic payload, Options? options, CancelToken? cancelToken, ProgressCallback? onUploadProgress}) {
    return _client.post<T>(uri, data: payload, onSendProgress: onUploadProgress, options: options, cancelToken: cancelToken).catchError((e) => _handleError(e))
        .then((response) => response.data!);
  }

  Future<T> put<T>(String uri, [payload]) {
    payload = _spoofHttpMethod('PUT', payload);
    return _client.post<T>(uri, data: payload).catchError((e) => _handleError(e))
        .then((response) => response.data!);
  }

  Future<T> delete<T>(String uri, [payload]) {
    payload = _spoofHttpMethod('DELETE', payload);
    return _client.delete<T>(uri, data: payload).catchError((e) => _handleError(e))
        .then((response) => response.data!);
  }

  prefixUrl(String url) {
    if (url.contains('://') || url.startsWith(baseBackendUrl!) || url.startsWith('api')) {
      return url;
    }
    if (url.startsWith('/')) {
      url = url.substring(1);
    }
    return '$baseBackendUrl/$url';
  }
  
  setErrorHandler(AppHttpClientErrorHandler handler) {
    errorHandlers.add(handler);
  }

  _spoofHttpMethod(String method, Map? original) {
    final payload = Map<String, dynamic>.from(original ?? {});
    payload['_method'] = method;
    return payload;
  }

  _handleError(DioError e) {
    final backendError = BackendError(dioError: e);
    errorHandlers.forEach((handler) => handler(backendError));
    throw(backendError);
  }
}
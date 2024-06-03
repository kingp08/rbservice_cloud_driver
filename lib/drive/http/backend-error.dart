import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

const GENERIC_ERROR_MESSAGE = 'An unknown error occurred. Please try again.';
const NO_CONNECTION_MESSAGE = 'No network connection. Reconnect and try again.';

class BackendError implements Exception {
  Map<String, String> errors = {};
  String? message;
  int? status;
  bool? isCancel = false;
  bool? noInternet = false;
  String? uri;

  BackendError({DioError? dioError, dynamic errResponse = const {}, String? message}) {
    errResponse = dioError?.response?.data ?? errResponse ?? {};
    if (errResponse is String) {
      errResponse = json.decode(errResponse);
    }

    isCancel = dioError != null && CancelToken.isCancel(dioError);
    noInternet = dioError != null && dioError.error is SocketException;
    uri = dioError?.requestOptions.uri.toString();

    if (errResponse['errors'] != null) {
      errors = Map<String, dynamic>.from(errResponse['errors']).map((key, value) {
        return MapEntry(key, value is List ? value.first : value);
      });
    }

    if (message == null) {
      if (errors.values.isNotEmpty) {
        message = errors.values.first;
      } else {
        message = errResponse['message'];
      }
    }

    if (message == null || message == '') {
      message = noInternet! ? NO_CONNECTION_MESSAGE : GENERIC_ERROR_MESSAGE;
    }

    status = dioError?.response?.statusCode ?? 500;
    this.message = message;
  }

  factory BackendError.fromRawJson(String str) => BackendError.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() {
    return {
      "errors": errors,
      "message": message,
      "status": status,
      "isCancel": isCancel,
      "noInternet": noInternet,
      "uri": uri,
    };
  }

  factory BackendError.fromJson(Map<String, dynamic> e) {
    final be = BackendError();
    be.message = e["message"];
    be.errors = Map<String, String>.from(e["errors"]);
    be.status = e["status"];
    be.isCancel = e["isCancel"];
    be.noInternet = e["noInternet"];
    return be;
  }


  @override
  String toString() {
    return this.toRawJson();
  }
}
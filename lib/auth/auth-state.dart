import 'package:bedrive/auth/auth-screen-wrapper.dart';
import 'package:bedrive/auth/device-identifier.dart';
import 'package:bedrive/auth/screens/login-screen.dart';
import 'package:bedrive/auth/social-buttons/social-login-button.dart';
import 'package:bedrive/auth/user.dart';
import 'package:bedrive/config/bootstrap-data-response.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/notifications/notifications.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:flutter/material.dart';

import 'dart:async';

const CURRENT_USER_FILE_NAME = 'currentUser.json';

class AuthState with ChangeNotifier {
  AuthState(this.httpClient, this.localStorage, this.notifications);
  final AppHttpClient httpClient;
  final Notifications notifications;
  LocalStorage localStorage;

  User? currentUser;
  bool loading = false;

  Future<AuthState> init() async {
    _setUser(await localStorage.permanent.get(CURRENT_USER_FILE_NAME),
        storeLocally: false);
    httpClient.setErrorHandler((BackendError e) {
      if (e.status == 401 && rootNavigatorKey.currentState != null) {
        logout(rootNavigatorKey.currentContext!,
            message: 'Your session has expired. Please sign in again.');
      }
    });
    return this;
  }

  login(Map<String, String?> payload) async {
    toggleLoading(true);
    payload['token_name'] = await deviceIdentifier();
    try {
      final response = BootstrapDataResponse.fromJson(
          await httpClient.post('/auth/login', payload: payload));
      _setUser(response.data!.user);
    } finally {
      toggleLoading(false);
    }
  }

  Future<BootstrapDataResponse> register(Map<String, String?> payload) async {
    toggleLoading(true);
    payload['token_name'] = await deviceIdentifier();
    try {
      final response = BootstrapDataResponse.fromJson(
          await httpClient.post('/auth/register', payload: payload));
      _setUser(response.data!.user);
      return response;
    } finally {
      toggleLoading(false);
    }
  }

  logout(BuildContext context, {String? message}) {
    localStorage.permanent.delete('currentUser.json');
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.ROUTE,
      (_) => false,
      arguments: AuthScreenArgs(message),
    );
  }

  Future<String?> sendPasswordResetLink(String? email) async {
    toggleLoading(true);
    try {
      return (await this
          .httpClient
          .post('/auth/password/email', payload: {'email': email}))['data'];
    } finally {
      toggleLoading(false);
    }
  }

  loginWithSocialService(SocialLoginProvider provider, String? accessToken,
      BuildContext context) async {
    toggleLoading(true);
    try {
      final response = BootstrapDataResponse.fromJson(await httpClient
          .get('/auth/social/${provider.value}/callback', params: {
        'tokenForDevice': await deviceIdentifier(),
        'tokenFromApi': accessToken
      }));
      _setUser(response.data!.user);
    } finally {
      toggleLoading(false);
    }
  }

  toggleLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  _setUser(dynamic userData, {bool storeLocally = true}) async {
    if (userData != null) {
      currentUser = userData is String ? User.fromRawJson(userData) : userData;
      httpClient.accessToken = currentUser!.backendToken;
      if (storeLocally) {
        await localStorage.permanent
            .put(CURRENT_USER_FILE_NAME, currentUser!.toRawJson());
      }
      _maybeUpdateFirebaseToken();
    }
  }

  _maybeUpdateFirebaseToken() async {
    final fcmToken = await notifications.fcm.getToken();
    if (fcmToken != currentUser!.fcmToken) {
      httpClient.post('/fcm-token', payload: {
        'token': fcmToken,
        'deviceId': await deviceIdentifier()
      }).catchError((_) {});
      currentUser!.fcmToken = fcmToken;
      localStorage.permanent
          .put(CURRENT_USER_FILE_NAME, currentUser!.toRawJson());
    }
  }
}

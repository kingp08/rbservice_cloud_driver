import 'dart:io';

import 'package:bedrive/auth/auth-input-decoration.dart';
import 'package:bedrive/auth/auth-screen-wrapper.dart';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/auth/screens/forgot-password-screen.dart';
import 'package:bedrive/auth/social-buttons/social-login-button.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/utils/bool-to-int.dart';
import 'package:bedrive/utils/text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static const ROUTE = 'login';
  final Map<String, String> backendErrors = {};
  final _loginFormKey = GlobalKey<FormState>();
  final Map<String, String?> formPayload = {};

  @override
  Widget build(BuildContext context) {
    final bool loading = context.select((AuthState s) => s.loading);
    final bool showGoogleBtn = context.select(
        (AppConfig c) => toBool(c.backendConfig?['social.google.enable']));
    return AuthScreenWrapper(
      title: text('Sign in to your account', size: 18),
      screen: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                onSaved: (v) => formPayload['email'] = v,
                keyboardType: TextInputType.emailAddress,
                decoration: authInputDecoration(Icons.email_outlined, 'Email'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans('This field cannot be empty.');
                  } else if (!EmailValidator.validate(value)) {
                    return trans('This field requires a valid email address.');
                  } else if (backendErrors['email'] != null) {
                    return backendErrors['email'];
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                onSaved: (v) => formPayload['password'] = v,
                obscureText: true,
                decoration: authInputDecoration(Icons.lock_outline, 'Password'),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: loading ? null : (_) => _login(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans('This field cannot be empty.');
                  } else if (backendErrors['password'] != null) {
                    return backendErrors['password'];
                  }
                  return null;
                },
              ),
              Align(
                child: TextButton(
                  child: text('Forgot password?',
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.of(context).pushNamed(ForgotPasswordScreen.ROUTE);
                  },
                ),
                alignment: Alignment.centerRight,
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 51,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: text('Sign In'),
                  onPressed: loading ? null : () => _login(context),
                ),
              ),
              SizedBox(height: 10),
              Platform.isAndroid && showGoogleBtn
                  ? LoginWithGoogleButton(SocialLoginProvider.google)
                  : Container(),
              SizedBox(height: 10),
            ],
          )),
      footer: AuthScreenWrapperFooter.toRegister,
    );
  }

  _login(BuildContext context) async {
    backendErrors.clear();
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      try {
        await context.read<AuthState>().login(formPayload);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(RootScreen.ROUTE, (_) => false);
      } on BackendError catch (e) {
        if (e.errors.isNotEmpty) {
          backendErrors.addAll(e.errors);
          _loginFormKey.currentState!.validate();
        }
      }
    }
  }
}

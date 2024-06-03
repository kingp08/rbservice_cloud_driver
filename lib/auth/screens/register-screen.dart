import 'dart:io';
import 'package:bedrive/auth/auth-input-decoration.dart';
import 'package:bedrive/auth/auth-screen-wrapper.dart';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/auth/screens/login-screen.dart';
import 'package:bedrive/auth/social-buttons/social-login-button.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  static const ROUTE = 'register';
  final Map<String, String> backendErrors = {};
  final _formKey = GlobalKey<FormState>();
  final Map<String, String?> formPayload = {};

  @override
  Widget build(BuildContext context) {
    final bool loading = context.select((AuthState s) => s.loading);
    return AuthScreenWrapper(
      title: text('Create a new account', size: 18),
      screen: Builder(
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
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
                    } else if ( ! EmailValidator.validate(value)) {
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
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return trans('This field cannot be empty.');
                    } else if (backendErrors['password'] != null) {
                      return backendErrors['password'];
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  onSaved: (v) => formPayload['password_confirmation'] = v,
                  obscureText: true,
                  decoration: authInputDecoration(Icons.lock, 'Confirm Password'),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: loading ? null : (_) => _register(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return trans('This field cannot be empty.');
                    } else if (backendErrors['password_confirmation'] != null) {
                      return backendErrors['password_confirmation'];
                    }
                    return null;
                  },
                ),
                SizedBox(height: 35),
                SizedBox(
                  height: 51,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: text('Create Account'),
                    onPressed: loading ? null : () => _register(context),
                  ),
                ),
                SizedBox(height: 10),
                Platform.isAndroid ? LoginWithGoogleButton(SocialLoginProvider.google) : Container(),
                SizedBox(height: 10),
              ],
            )
          );
        },
      ),
      footer: AuthScreenWrapperFooter.toLogin,
    );
  }

  _register(BuildContext context) async {
    backendErrors.clear();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await context.read<AuthState>().register(formPayload);
        if (response.status == 'needs_email_verification') {
          Navigator.of(context).pushReplacementNamed(LoginScreen.ROUTE, arguments: AuthScreenArgs(trans(response.message)));
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(RootScreen.ROUTE, (_) => false);
        }
      } on BackendError catch(e) {
        if (e.errors.isNotEmpty) {
          backendErrors.addAll(e.errors);
          _formKey.currentState!.validate();
        }
      }
    }
  }
}
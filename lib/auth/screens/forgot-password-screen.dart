import 'package:bedrive/auth/auth-input-decoration.dart';
import 'package:bedrive/auth/auth-screen-wrapper.dart';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/auth/screens/login-screen.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/utils/text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const ROUTE = 'forgotPassword';
  final Map<String, String?> backendErrors = {};
  final _formKey = GlobalKey<FormState>();
  final Map<String, String?> formPayload = {};

  @override
  Widget build(BuildContext context) {
    final bool loading = context.select((AuthState s) => s.loading);
    return AuthScreenWrapper(
      title: text(
          'Enter your email address below and we will send you a link to reset or create your password.',
          singleLine: false,
          height: 1.2),
      screen: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onSaved: (v) => formPayload['email'] = v,
                keyboardType: TextInputType.emailAddress,
                decoration: authInputDecoration(Icons.email_outlined, 'Email'),
                textInputAction: TextInputAction.done,
                onFieldSubmitted:
                    loading ? null : (_) => _sendResetLink(context),
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
              SizedBox(height: 25),
              SizedBox(
                height: 51,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: text('Continue'),
                  onPressed: loading ? null : () => _sendResetLink(context),
                ),
              ),
              SizedBox(height: 10),
            ],
          )),
    );
  }

  _sendResetLink(BuildContext context) async {
    backendErrors.clear();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final message = await context
            .read<AuthState>()
            .sendPasswordResetLink(formPayload['email']);
        Navigator.of(context).pushReplacementNamed(LoginScreen.ROUTE,
            arguments: AuthScreenArgs(message));
      } on BackendError catch (e) {
        backendErrors.addAll({'email': e.message});
        _formKey.currentState!.validate();
      }
    }
  }
}

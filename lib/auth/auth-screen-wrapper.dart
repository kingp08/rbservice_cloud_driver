import 'dart:math';

import 'package:bedrive/drive/dialogs/show-message-dialog.dart';
import 'package:bedrive/drive/state/preference-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthScreenWrapperFooter {
  toLogin,
  toRegister,
}

class AuthScreenArgs {
  AuthScreenArgs(this.message);
  final String? message;
}

class AuthScreenWrapper extends StatefulWidget {
  AuthScreenWrapper({
    Key? key,
    required this.screen,
    this.footer,
    required this.title,
  }) : super(key: key);

  final Widget screen;
  final AuthScreenWrapperFooter? footer;
  final Text title;

  @override
  _AuthScreenWrapperState createState() => _AuthScreenWrapperState();
}

class _AuthScreenWrapperState extends State<AuthScreenWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowMessageDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (BuildContext context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return SafeArea(
            child: SingleChildScrollView(
                child: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  constraints: BoxConstraints(
                      maxWidth:
                          min(MediaQuery.of(context).size.width - 70, 450)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image: isDarkMode
                            ? AssetImage('assets/logos/logo-light.png')
                            : AssetImage('assets/logos/logo-dark.png'),
                        height: 36.0,
                      ),
                      SizedBox(height: 60),
                      widget.title,
                      SizedBox(height: 20),
                      widget.screen,
                      SizedBox(height: 10),
                      _Footer(footer: widget.footer),
                    ],
                  )),
            )),
          );
        },
      ),
    );
  }

  _maybeShowMessageDialog() {
    final args =
        (ModalRoute.of(context)!.settings.arguments as AuthScreenArgs?);
    if (args != null && args.message != null) {
      showMessageDialog(context, args.message);
    }
  }
}

class _Footer extends StatelessWidget {
  _Footer({
    Key? key,
    this.footer,
  }) : super(key: key);

  final AuthScreenWrapperFooter? footer;

  @override
  Widget build(BuildContext context) {
    if (footer == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text(footer == AuthScreenWrapperFooter.toRegister
            ? "Don't have an account?"
            : 'Already have an account?'),
        TextButton(
          child: text(
              footer == AuthScreenWrapperFooter.toRegister
                  ? 'Sign up'
                  : 'Sign in',
              color: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(context).pushNamed(
                footer == AuthScreenWrapperFooter.toRegister
                    ? 'register'
                    : 'login');
          },
        )
      ],
    );
  }
}

import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/drive/dialogs/show-message-dialog.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

enum SocialLoginProvider {
  google,
  apple,
}

extension SocialLoginButton on SocialLoginProvider {
  String get value => describeEnum(this);
  Color get backgroundColor {
    switch (this) {
      case SocialLoginProvider.google:
        return Colors.white;
      case SocialLoginProvider.apple:
        return Colors.black;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case SocialLoginProvider.google:
        return Colors.black87;
      case SocialLoginProvider.apple:
        return Colors.white70;
    }
  }
}

class LoginWithGoogleButton extends StatelessWidget {
  const LoginWithGoogleButton(
    this.provider, {
    Key? key,
  }) : super(key: key);
  final SocialLoginProvider provider;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthState s) => s.loading);
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: provider.backgroundColor,
            foregroundColor: provider.foregroundColor),
        icon: _Icon(provider),
        label: text('Sign in with ${provider.value.capitalize()}'),
        onPressed: isLoading ? null : () => _login(context, provider),
      ),
    );
  }
}

_login(BuildContext context, SocialLoginProvider provider) {
  switch (provider) {
    case SocialLoginProvider.apple:
      return _loginWithApple(context);
    default:
      return _loginWithGoogle(context);
  }
}

_loginWithApple(BuildContext context) async {
  //
}

_loginWithGoogle(BuildContext context) async {
  final googleSignIn = GoogleSignIn(scopes: ['email']);
  try {
    final account = await googleSignIn.signIn();
    if (account != null) {
      await context.read<AuthState>().loginWithSocialService(
            SocialLoginProvider.google,
            (await account.authentication).accessToken,
            context,
          );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RootScreen.ROUTE, (_) => false);
    }
  } catch (e) {
    String? msg;
    if (e is BackendError) {
      msg = e.message;
    } else if (e is PlatformException) {
      msg = e.message;
    } else {
      msg = GENERIC_ERROR_MESSAGE;
    }
    showMessageDialog(context, msg);
  }
}

class _Icon extends StatelessWidget {
  const _Icon(
    this.provider, {
    Key? key,
  }) : super(key: key);
  final SocialLoginProvider provider;

  @override
  Widget build(BuildContext context) {
    String logo =
        provider == SocialLoginProvider.apple ? 'apple-white' : provider.value;
    return SvgPicture.asset(
      'assets/social-logos/$logo-logo.svg',
      height: 26,
      width: 26,
    );
  }
}

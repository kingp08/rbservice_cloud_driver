import 'package:bedrive/drive/screens/file-list/error-indicators/base-indicator.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/http/backend-error.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    required this.error,
    this.onTryAgain,
    this.compact = false,
    Key? key,
  })  : assert(error != null),
        super(key: key);

  final BackendError error;
  final VoidCallback? onTryAgain;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (error.noInternet!) {
      return BaseIndicator(
        title: 'No connection',
        message: 'Please check internet connection and try again.',
        assetPath: 'assets/icons/no-connection.svg',
        onTryAgain: onTryAgain,
        compact: compact,
      );
    } else {
      return BaseIndicator(
        title: 'Something went wrong',
        message: error.message,
        assetPath: 'assets/icons/warning-cyit.svg',
        onTryAgain: onTryAgain,
        compact: compact,
      );
    }
  }
}

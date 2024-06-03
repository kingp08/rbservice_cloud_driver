import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BaseIndicator extends StatelessWidget {
  BaseIndicator({
    required this.title,
    required this.assetPath,
    this.message,
    this.onTryAgain,
    this.compact = false,
    Key? key,
  }) : super(key: key);
  final String? title;
  final String? message;
  final String assetPath;
  final VoidCallback? onTryAgain;
  final bool compact;

  Widget _icon() {
    if (assetPath.endsWith('svg')) {
      return SvgPicture.asset(assetPath, width: 74, height: 74);
    } else {
      return Image(image: AssetImage(assetPath), width: 74, height: 74);
    }
  }

  Text _title(BuildContext context) {
    return text(
      title,
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Text _subtitle(BuildContext context) {
    return text(
      message,
      color: Theme.of(context).textTheme.caption!.color,
      singleLine: false,
      align: TextAlign.center,
    );
  }

  Widget _largeTryAgainButton(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
        onPressed: onTryAgain,
        icon: const Icon(
          Icons.refresh,
        ),
        label: text('Try Again', size: 16),
      ),
    );
  }

  Widget _smallTryAgainButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text(
          message ?? title,
          align: TextAlign.center,
        ),
        onTryAgain != null ? IconButton(icon: Icon(Icons.refresh), onPressed: onTryAgain) : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _smallTryAgainButton();
    } else {
      final children = <Widget>[];
      children.add(_icon());
      children.add(SizedBox(height: 32));
      children.add(_title(context));
      if (message != null) {
        children.add(SizedBox(height: 10));
        children.add(_subtitle(context));
      }
      if (onTryAgain != null) {
        children.add(Spacer());
        children.add(_largeTryAgainButton(context));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
  }
}

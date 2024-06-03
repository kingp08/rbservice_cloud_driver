import 'dart:async';
import 'dart:io';

import 'package:bedrive/utils/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _modalBarrierDefaultColor = Colors.black54;
bool _loaderIsShown = false;
OverlayEntry? _overlayEntry;
late BuildContext _loadingDialogContext;
Completer? _closeOverlayCompleter;
bool _dismissible = false;

class LoadingDialog {
  static isShown() => _loaderIsShown;

  static Future<void> show({String? message = 'Please wait...', Widget? child, bool dismissible = false}) {
    if (LoadingDialog.isShown()) return _closeOverlayCompleter!.future;
    _loaderIsShown = true;
    _dismissible = dismissible;

    if (child == null) {
      child = Row(
        children: [
          (Platform.isAndroid ? CircularProgressIndicator() : CupertinoActivityIndicator()),
          SizedBox(width: 20),
          text(message, color: Theme.of(_loadingDialogContext).textTheme.bodyText2!.color, size: 16),
        ]
      );
    }

    final loader = Stack(
      children: <Widget>[
        ModalBarrier(color: _modalBarrierDefaultColor, dismissible: false),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(_loadingDialogContext).size.width * 0.90),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: child,
              ),
            ),
          )
        ),
      ],
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => loader
    );

    Overlay.of(_loadingDialogContext)!.insert(_overlayEntry!);
    _closeOverlayCompleter = Completer();
    return _closeOverlayCompleter!.future;
  }

  static hide() {
    _loaderIsShown = false;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (_closeOverlayCompleter != null) {
      _closeOverlayCompleter!.complete();
      _closeOverlayCompleter = null;
    }
    _dismissible = false;
  }
}

WillPopScope loadingWillPopScope(Widget child) {
  return WillPopScope(
    child: Builder(builder: (BuildContext context) {
      _loadingDialogContext = context;
      return child;
    }),
    onWillPop: () async {
      if ( ! LoadingDialog.isShown()) {
        return true;
      }
      if (_dismissible) {
        LoadingDialog.hide();
      }
      return false;
    },
  );
}
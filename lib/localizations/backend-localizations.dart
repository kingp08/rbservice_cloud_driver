import 'package:flutter/material.dart';

class BackendLocalizations {
  BackendLocalizations(this.lines);
  final Map<String, String> lines;

  static BackendLocalizations? of(BuildContext context) {
    return Localizations.of<BackendLocalizations>(context, BackendLocalizations);
  }

  String? trans(String? message) {
    if (lines == null) {
      return message;
    }
    return lines[message!] ?? message;
  }
}
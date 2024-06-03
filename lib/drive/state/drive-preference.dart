import 'package:flutter/foundation.dart';

enum DrivePreference {
  fileListMode,
  themeMode,
}

extension DrivePreferenceExtension on DrivePreference {
  String get value => describeEnum(this);
}
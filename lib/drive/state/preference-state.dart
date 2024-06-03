import 'package:bedrive/drive/screens/file-list/file-list-mode.dart';
import 'package:bedrive/drive/state/drive-preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceState with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ThemeMode themeMode = ThemeMode.system;
  FileListMode fileListMode = FileListMode.grid;

  Future<FileListMode> setFileListMode(FileListMode mode) async {
    (await _prefs).setString(DrivePreference.fileListMode.value, mode.value);
    fileListMode = mode;
    notifyListeners();
    return mode;
  }

  Future<ThemeMode> setThemeMode(ThemeMode mode) async {
    (await _prefs).setString(DrivePreference.themeMode.value, describeEnum(mode));
    themeMode = mode;
    notifyListeners();
    return mode;
  }

  init() async {
    final prefs = await _prefs;
    fileListMode = FileListMode.grid.fromValue(prefs.getString(DrivePreference.fileListMode.value));
    _initThemeMode();
    notifyListeners();
  }

  _initThemeMode() async {
    String? _themeMode = (await _prefs).getString(DrivePreference.themeMode.value);
    if (_themeMode == describeEnum(ThemeMode.light)) {
      themeMode = ThemeMode.light;
    } else if (_themeMode == describeEnum(ThemeMode.dark)) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
  }
}
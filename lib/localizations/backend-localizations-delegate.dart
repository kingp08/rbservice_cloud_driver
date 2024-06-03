import 'dart:io';
import 'package:bedrive/localizations/backend-locale.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/localizations/backend-localizations.dart';
import 'package:path_provider/path_provider.dart';

class BackendLocalizationsDelegate extends LocalizationsDelegate<BackendLocalizations> {
  const BackendLocalizationsDelegate(this.appConfig);
  final AppConfig appConfig;

  @override
  bool isSupported(Locale locale) => appConfig.locales[locale.languageCode] != null;

  @override
  Future<BackendLocalizations> load(Locale locale) async {
    final backendLocale = await _loadBackendLocale(locale.languageCode);
    return BackendLocalizations(backendLocale?.lines ?? {});
  }

  @override
  bool shouldReload(BackendLocalizationsDelegate old) => false;

  Future<BackendLocale?> _loadBackendLocale(String langCode) async {
    final cacheFile = File(await _getCachedLocalePath(langCode));
    final cachedLocale = await _getValidCachedLocale(cacheFile, langCode);
    if (cachedLocale != null) {
      return cachedLocale;
    } else {
      try {
        final response = await appConfig.httpClient!.get('/localizations/$langCode');
        final locale = BackendLocale.fromJson(
          response['localization'],
          response['localization']['lines'],
        );
        cacheFile.writeAsString(locale.toRawJson());
        return locale;
      } catch(e) {
        return null;
      }
    }
  }

  Future<BackendLocale?> _getValidCachedLocale(File cachedLocaleFile, String langCode) async {
    if (await cachedLocaleFile.exists()) {
      final cachedLocale = BackendLocale.fromRawJson(await cachedLocaleFile.readAsString());
      if (cachedLocale.lines != null && (appConfig.locales[langCode]!.updatedAt == null || !cachedLocale.updatedAt!.isBefore(appConfig.locales[langCode]!.updatedAt!))) {
        return cachedLocale;
      }
    }
    return null;
  }

  _getCachedLocalePath(String langCode) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/$langCode.json';
  }
}
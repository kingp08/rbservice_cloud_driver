import 'dart:convert';
import 'package:bedrive/config/bootstrap-data-response.dart';
import 'package:bedrive/config/dynamic-menu.dart';
import 'package:bedrive/config/local-config.dart';
import 'package:bedrive/config/themes/backend-theme-config.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/localizations/backend-locale.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

class AppConfig {
  AppHttpClient? httpClient;
  String? appName;
  String? version;
  BackendThemeConfig? lightThemeConfig;
  BackendThemeConfig? darkThemeConfig;
  final Map<MenuPosition?, DynamicMenu> menus = {};
  final Map<String?, BackendLocale> locales = {};
  late LocalConfig localConfig;
  Map<String, dynamic>? backendConfig;

  Future<AppConfig> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    version = packageInfo.version;

    YamlMap local = loadYaml(await rootBundle.loadString('app-config.yaml'));
    localConfig = LocalConfig.fromJson(Map.from(local));

    httpClient =
        AppHttpClient(localConfig.baseBackendUrl, localConfig.apiVersion);

    try {
      final response = BootstrapDataResponse.fromJson(
          await httpClient!.get('/remote-config/mobile'));
      if (response.data != null) {
        _initThemes(response.data!.themes!);
        _initLocales(response.data!.locales);
        _initMenus(response.data!.menus);
        backendConfig = response.data!.settings ?? {};
      } else {
        _initWithDefaultValues();
      }
    } on BackendError catch (_) {
      _initWithDefaultValues();
    }

    return this;
  }

  _initThemes(BootstrapDataThemes bootstrapThemes) {
    lightThemeConfig = bootstrapThemes.light;
    darkThemeConfig = bootstrapThemes.dark;
  }

  _initLocales(List<BackendLocale>? bootstrapLocales) {
    if (bootstrapLocales != null) {
      bootstrapLocales.forEach((locale) {
        locales[locale.language] = locale;
      });
    }
  }

  _initMenus(List<DynamicMenu>? bootstrapMenus) {
    if (bootstrapMenus != null) {
      bootstrapMenus.forEach((menu) {
        menus[menu.position] = menu;
      });
    }
  }

  _initWithDefaultValues() async {
    locales['en'] = BackendLocale();
    final decoded =
        json.decode(await rootBundle.loadString('assets/config/themes.json'));
    _initThemes(BootstrapDataThemes.fromJson(decoded['themes']));
  }
}

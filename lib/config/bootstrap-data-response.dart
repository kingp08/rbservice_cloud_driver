import 'dart:convert';
import 'package:bedrive/auth/user.dart';
import 'package:bedrive/config/dynamic-menu.dart';
import 'package:bedrive/config/themes/backend-theme-config.dart';
import 'package:bedrive/localizations/backend-locale.dart';

class BootstrapDataResponse {
  BootstrapDataResponse({
    this.status,
    this.data,
    this.message,
  });

  final String? status;
  final String? message;
  final BoostrapData? data;

  factory BootstrapDataResponse.fromRawJson(String str) => BootstrapDataResponse.fromJson(json.decode(str));

  factory BootstrapDataResponse.fromJson(Map<String, dynamic> json) {
    String? status = json["status"] == null ? 'unknown' : json["status"];
    dynamic data;

    if (json["boostrapData"] != null) {
      data = json["boostrapData"];
    } else if (json["data"] != null) {
      data = json["data"];
    } else if (json is Map) {
      data = json;
    }

    return BootstrapDataResponse(
      status: status,
      data: BoostrapData.fromJson(data),
      message: json["message"] == null ? null : json["message"],
    );
  }
}

class BoostrapData {
  BoostrapData({
    this.themes,
    this.user,
    this.menus,
    this.locales,
    this.settings,
  });

  final BootstrapDataThemes? themes;
  final User? user;
  final List<DynamicMenu>? menus;
  final List<BackendLocale>? locales;
  final Map<String, dynamic>? settings;

  factory BoostrapData.fromRawJson(String str) => BoostrapData.fromJson(json.decode(str));

  factory BoostrapData.fromJson(Map<String, dynamic> json) => BoostrapData(
    themes: json["themes"] == null ? null : BootstrapDataThemes.fromJson(json["themes"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    menus: json["menus"] == null ? null : List<DynamicMenu>.from(json["menus"].map((x) => DynamicMenu.fromJson(x))),
    locales: json["locales"] == null ? null : List<BackendLocale>.from(json["locales"].map((x) => BackendLocale.fromJson(x))),
    settings: json['settings'] == null ? null : json['settings'],
  );
}

class BootstrapDataThemes {
  BootstrapDataThemes({
    this.dark,
    this.light,
    this.selected,
  });

  final BackendThemeConfig? dark;
  final BackendThemeConfig? light;
  final String? selected;

  factory BootstrapDataThemes.fromRawJson(String str) => BootstrapDataThemes.fromJson(json.decode(str));

  factory BootstrapDataThemes.fromJson(Map<String, dynamic> json) => BootstrapDataThemes(
    dark: json["dark"] == null ? null : BackendThemeConfig.fromJson(json["dark"]),
    light: json["light"] == null ? null : BackendThemeConfig.fromJson(json["light"]),
    selected: json["selected"] == null ? null : json["selected"],
  );
}

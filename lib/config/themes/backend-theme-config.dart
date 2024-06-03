import 'dart:convert';

import 'dart:ui';

class BackendThemeConfig {
  BackendThemeConfig({
    this.id,
    this.name,
    this.isDark,
    this.defaultLight,
    this.defaultDark,
    this.userId,
    this.colors,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  bool? isDark;
  bool? defaultLight;
  bool? defaultDark;
  int? userId;
  Map<String, Color>? colors;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory BackendThemeConfig.fromRawJson(String str) => BackendThemeConfig.fromJson(json.decode(str));

  factory BackendThemeConfig.fromJson(Map<String, dynamic> json) => BackendThemeConfig(
    id: json["id"],
    name: json["name"],
    isDark: json["is_dark"],
    defaultLight: json["default_light"],
    defaultDark: json["default_dark"],
    userId: json["user_id"],
    colors: _buildColors(json["colors"]),
    createdAt: json["created_at"] == null ? DateTime.now() : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? DateTime.now() : DateTime.parse(json["updated_at"]),
  );
}

Map<String, Color> _buildColors(dynamic colorConfig) {
  final colors = new Map<String, Color>();
  if (colorConfig != null) {

    final fb = colorConfig['--be-foreground-base'];
    colors['foreground-base'] = Color.fromRGBO(fb[0], fb[1], fb[2], 1);

    final p = colorConfig['--be-primary'];
    colors['primary'] = Color.fromRGBO(p[0], p[1], p[2], 1);

    final pl = colorConfig['--be-primary-light'];
    colors['primary-light'] = Color.fromRGBO(pl[0], pl[1], pl[2], 1);

    final pd = colorConfig['--be-primary-dark'];
    colors['primary-dark'] = Color.fromRGBO(pd[0], pd[1], pd[2], 1);

    final op = colorConfig['--be-on-primary'];
    colors['on-primary'] = Color.fromRGBO(op[0], op[1], op[2], 1);

    final bg = colorConfig['--be-background'];
    colors['background'] = Color.fromRGBO(bg[0], bg[1], bg[2], 1);

    final bgAlt = colorConfig['--be-background-alt'];
    colors['background-alt'] = Color.fromRGBO(bgAlt[0], bgAlt[1], bgAlt[2], 1);

    final bgc = colorConfig['--be-background-chip'];
    colors['background-chip'] = Color.fromRGBO(bgc[0], bgc[1], bgc[2], 1);

    final tmo = colorConfig['--be-text-main-opacity'] / 100;
    colors['text-main'] = Color.fromRGBO(fb[0], fb[1], fb[2], tmo);

    final muo = colorConfig['--be-text-muted-opacity'] / 100;
    colors['text-muted'] = Color.fromRGBO(fb[0], fb[1], fb[2], muo);

    final dop = colorConfig['--be-divider-opacity'] / 100;
    colors['divider'] = Color.fromRGBO(fb[0], fb[1], fb[2], dop);

    final fo = colorConfig['--be-focus-opacity'] / 100;
    colors['emphasis'] = Color.fromRGBO(p[0], p[1], p[2], fo);

  }
  return colors;
}
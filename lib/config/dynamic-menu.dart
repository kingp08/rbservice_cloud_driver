import 'dart:convert';

import 'package:flutter/foundation.dart';

class DynamicMenu {
  DynamicMenu({
    this.position,
    this.items,
    this.name,
  });

  final MenuPosition? position;
  final List<MenuItem>? items;
  final String? name;

  factory DynamicMenu.fromRawJson(String str) => DynamicMenu.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DynamicMenu.fromJson(Map<String, dynamic> json) => DynamicMenu(
    position: MenuPosition.aboutSection,
    items: List<MenuItem>.from(json["items"].map((x) => MenuItem.fromJson(x))),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "position": describeEnum(MenuPosition.aboutSection),
    "items": List<dynamic>.from(items!.map((x) => x.toJson())),
    "name": name,
  };
}

class MenuItem {
  MenuItem({
    this.type,
    this.condition,
    this.label,
    this.action,
    this.id,
  });

  final String? type;
  final String? condition;
  final String? label;
  final String? action;
  final dynamic id;

  factory MenuItem.fromRawJson(String str) => MenuItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    type: json["type"],
    condition: json["condition"],
    label: json["label"],
    action: json["action"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "condition": condition,
    "label": label,
    "action": action,
    "id": id,
  };
}

enum MenuPosition {
  aboutSection,
}

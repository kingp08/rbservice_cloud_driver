import 'dart:convert';

class NotificationSubscription {
  NotificationSubscription({
    this.id,
    this.notifId,
    this.userId,
    this.channels,
  });

  final String? id;
  final String? notifId;
  final int? userId;
  final Channels? channels;

  factory NotificationSubscription.fromRawJson(String str) => NotificationSubscription.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationSubscription.fromJson(Map<String, dynamic> json) {
    return NotificationSubscription(
      id: json["id"],
      notifId: json["notif_id"],
      userId: json["user_id"],
      channels: Channels.fromJson(json["channels"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "notif_id": notifId,
    "user_id": userId,
    "channels": channels!.toJson(),
  };
}

class Channels {
  Channels({
    this.email,
    this.browser,
    this.mobile,
  });

  final bool? email;
  final bool? browser;
  final bool? mobile;

  factory Channels.fromRawJson(String str) => Channels.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Channels.fromJson(Map<String, dynamic> json) => Channels(
    email: json["email"],
    browser: json["browser"],
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "browser": browser,
    "mobile": mobile,
  };
}
import 'dart:convert';

class NotificationPayload {
  NotificationPayload({
    this.notifId,
  });

  final String? notifId;

  factory NotificationPayload.fromRawJson(String str) => NotificationPayload.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationPayload.fromJson(Map<String, dynamic> json) => NotificationPayload(
    notifId: json["notifId"] == null ? null : json["notifId"],
  );

  Map<String, dynamic> toJson() => {
    "notifId": notifId == null ? null : notifId,
  };
}

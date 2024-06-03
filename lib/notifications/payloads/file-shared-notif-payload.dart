import 'dart:convert';
import 'package:bedrive/notifications/payloads/notification-payload.dart';

class FileSharedNotifPayload extends NotificationPayload {
  FileSharedNotifPayload({
    required this.entryId,
    required this.multiple,
    required this.notifId,
  });

  final int entryId;
  final bool multiple;
  final String notifId;

  factory FileSharedNotifPayload.fromRawJson(String str) => FileSharedNotifPayload.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileSharedNotifPayload.fromJson(Map<String, dynamic> json) => FileSharedNotifPayload(
    entryId: json["entryId"] == null ? 0 : int.parse(json["entryId"]),
    multiple: json["multiple"] != null && json["multiple"] == 'true',
    notifId: json["notifId"] == null ? null : json["notifId"],
  );

  Map<String, dynamic> toJson() => {
    "entryId": entryId,
    "multiple": multiple,
    "notifId": notifId,
  };
}

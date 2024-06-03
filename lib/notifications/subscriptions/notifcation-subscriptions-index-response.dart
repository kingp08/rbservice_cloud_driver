import 'dart:convert';

import 'package:bedrive/notifications/subscriptions/notification-subscription.dart';

class NotificationSubscriptionsIndexResponse {
  NotificationSubscriptionsIndexResponse({
    this.availableChannels,
    this.groupedNotifications,
    this.userSelections,
  });

  final List<String>? availableChannels;
  final List<GroupedNotification>? groupedNotifications;
  final List<NotificationSubscription>? userSelections;

  factory NotificationSubscriptionsIndexResponse.fromRawJson(String str) => NotificationSubscriptionsIndexResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationSubscriptionsIndexResponse.fromJson(Map<String, dynamic> json) => NotificationSubscriptionsIndexResponse(
    availableChannels: List<String>.from(json["available_channels"].map((x) => x)),
    groupedNotifications: List<GroupedNotification>.from(json["subscriptions"].map((x) => GroupedNotification.fromJson(x))),
    userSelections: List<NotificationSubscription>.from(json["user_selections"].map((x) => NotificationSubscription.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "available_channels": List<dynamic>.from(availableChannels!.map((x) => x)),
    "grouped_notifications": List<dynamic>.from(groupedNotifications!.map((x) => x.toJson())),
    "user_selections": List<dynamic>.from(userSelections!.map((x) => x.toJson())),
  };
}

class GroupedNotification {
  GroupedNotification({
    this.groupName,
    this.notifications,
  });

  final String? groupName;
  final List<Notification>? notifications;

  factory GroupedNotification.fromRawJson(String str) => GroupedNotification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GroupedNotification.fromJson(Map<String, dynamic> json) => GroupedNotification(
    groupName: json["group_name"],
    notifications: List<Notification>.from(json["subscriptions"].map((x) => Notification.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "group_name": groupName,
    "notifications": List<dynamic>.from(notifications!.map((x) => x.toJson())),
  };
}

class Notification {
  Notification({
    this.name,
    this.notifId,
  });

  final String? name;
  final String? notifId;

  factory Notification.fromRawJson(String str) => Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    name: json["name"],
    notifId: json["notif_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "notif_id": notifId,
  };
}
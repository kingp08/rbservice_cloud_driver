import 'dart:convert';

class User {
  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.gender,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.language,
    this.country,
    this.timezone,
    this.avatar,
    this.availableSpace,
    this.emailVerifiedAt,
    this.displayName,
    this.backendToken,
    this.fcmToken,
  });

  final int? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? language;
  final String? country;
  final String? timezone;
  final String? avatar;
  final int? availableSpace;
  final DateTime? emailVerifiedAt;
  final String? displayName;
  final String? backendToken;
  String? fcmToken;

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gender: json["gender"],
    email: json["email"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    language: json["language"],
    country: json["country"],
    timezone: json["timezone"],
    avatar: json["avatar"],
    availableSpace: json["available_space"],
    emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
    displayName: json["display_name"],
    backendToken: json["access_token"],
    fcmToken: json["fcm_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "gender": gender,
    "email": email,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "language": language,
    "country": country,
    "timezone": timezone,
    "avatar": avatar,
    "available_space": availableSpace,
    "email_verified_at": emailVerifiedAt == null ? null : emailVerifiedAt!.toIso8601String(),
    "display_name": displayName,
    "access_token": backendToken,
    "fcm_token": fcmToken,
  };
}

import 'dart:convert';

import 'package:bedrive/drive/state/drive-state.dart';

class Pagination {
  Pagination({
    this.currentPage,
    this.from,
    this.lastPage,
    this.perPage = DriveState.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  int? perPage;
  int? to;
  int? total;

  factory Pagination.fromRawJson(String str) => Pagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    perPage: json["per_page"] is int ? json["per_page"] : int.parse(json["per_page"]),
    to: json["to"],
    total: json["total"],
  );

  factory Pagination.empty() => Pagination(
    currentPage: 1,
    from: 0,
    lastPage: 1,
    perPage: DriveState.perPage,
    to: 0,
    total: 0,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}
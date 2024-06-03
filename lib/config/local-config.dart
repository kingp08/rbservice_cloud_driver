import 'dart:convert';

const DEFAULT_API_VERSION = 'v1';

class LocalConfig {
  LocalConfig({
    this.baseBackendUrl,
    this.sentryDsn,
    this.apiVersion = DEFAULT_API_VERSION,
  });

  final String? baseBackendUrl;
  final String? apiVersion;
  final String? sentryDsn;

  factory LocalConfig.fromRawJson(String str) => LocalConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LocalConfig.fromJson(Map<String, dynamic> json) {
    String? backendUrl = json["backend_url"];
    return LocalConfig(
      baseBackendUrl: backendUrl,
      sentryDsn: json["sentry_dsn"],
      apiVersion: json["api_version"] == null ? DEFAULT_API_VERSION : json["api_version"],
    );
  }

  Map<String, dynamic> toJson() => {
    "backend_url": baseBackendUrl == null ? null : baseBackendUrl,
    "api_version": apiVersion == null ? null : apiVersion,
    "sentry_dsn": sentryDsn == null ? null : sentryDsn,
  };
}

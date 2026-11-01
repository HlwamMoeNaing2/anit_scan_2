import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.enableHttpLogs = false,
    this.certificateSha256Pins = const [],
  });

  /// Origin of the government API, with a trailing slash.
  final String baseUrl;

  final bool enableHttpLogs;

  /// Lowercase hex SHA-256 of the server certificate DER.
  /// Empty keeps normal system certificate checks and does not pin.
  final List<String> certificateSha256Pins;

  static ApiConfig fromEnvironment() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    return ApiConfig(
      baseUrl: normalizeBaseUrl(
        fromDefine.isEmpty ? 'https://api.example.com' : fromDefine,
      ),
      enableHttpLogs: kDebugMode,
    );
  }

  static String normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) return trimmed;
    return '$trimmed/';
  }
}

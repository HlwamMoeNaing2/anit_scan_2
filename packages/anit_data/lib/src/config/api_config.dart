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

  static String normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) return trimmed;
    return '$trimmed/';
  }
}

import 'package:flutter/foundation.dart';

/// Runtime configuration. Override the API with:
/// `flutter run --dart-define=API_BASE_URL=https://your.host`
class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    required this.enableHttpLogs,
  });

  final String apiBaseUrl;
  final bool enableHttpLogs;

  static AppEnvironment get current {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    return AppEnvironment(
      apiBaseUrl: fromDefine.isEmpty ? 'https://api.example.com' : fromDefine,
      enableHttpLogs: kDebugMode,
    );
  }
}

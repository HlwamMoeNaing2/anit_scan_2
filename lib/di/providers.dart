import 'package:anit_core/anit_core.dart';
import 'package:anit_data/anit_data.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_environment.dart';
import '../firebase/push_notification_service.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

final appLoggerProvider = Provider<AppLogger>((ref) {
  return _CrashlyticsLog(reportToCrashlytics: ref.watch(firebaseReadyProvider));
});

final apiConfigProvider = Provider<ApiConfig>((ref) {
  final environment = AppEnvironment.current;
  return ApiConfig(
    baseUrl: ApiConfig.normalizeBaseUrl(environment.apiBaseUrl),
    enableHttpLogs: environment.enableHttpLogs,
  );
});

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore(ref.watch(secureStoreProvider));
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw StateError('AppPreferences is created in bootstrap.');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(apiConfigProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    logger: ref.watch(appLoggerProvider),
  );
  ref.onDispose(client.close);
  return client;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

final class _CrashlyticsLog implements AppLogger {
  _CrashlyticsLog({required this.reportToCrashlytics});

  final bool reportToCrashlytics;

  @override
  void debug(String message) {
    if (kDebugMode) debugPrint(message);
  }

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) debugPrint(message);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) debugPrint(message);
    if (!reportToCrashlytics || Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordError(
      error ?? message,
      stackTrace,
      reason: message,
      fatal: false,
    );
  }
}

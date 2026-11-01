import 'package:core_common/core_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase/push_notification_service.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService();
});

final class CrashlyticsLog implements AppLogger {
  CrashlyticsLog({required this.reportToCrashlytics});

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

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Starts Crashlytics when the native Firebase files exist.
///
/// Add those files with FlutterFire, then this starts working on the next launch:
/// `dart pub global activate flutterfire_cli` and `flutterfire configure`.
/// Place `google-services.json` in `android/app` and `GoogleService-Info.plist`
/// in `ios/Runner` (and add the plist to the Runner target).
abstract final class FirebaseBootstrap {
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        kReleaseMode,
      );
      return true;
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          'Firebase is not configured yet. Crash reports stay on device until flutterfire configure is run.',
        );
      }
      return false;
    }
  }

  static void recordFlutterError(FlutterErrorDetails details) {
    if (Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  static void recordError(Object error, StackTrace stack) {
    if (Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}

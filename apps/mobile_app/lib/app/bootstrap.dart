import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anit_scan_app.dart';
import 'app_providers.dart';
import 'firebase/firebase_bootstrap.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferences.load();
  final firebaseReady = await FirebaseBootstrap.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseBootstrap.recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseBootstrap.recordError(error, stack);
    return true;
  };

  final container = ProviderContainer(
    overrides: [
      appPreferencesProvider.overrideWithValue(preferences),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
      appLoggerProvider.overrideWithValue(
        CrashlyticsLog(reportToCrashlytics: firebaseReady),
      ),
    ],
  );

  if (firebaseReady) {
    await container.read(pushNotificationServiceProvider).start();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AnitScanApp(),
    ),
  );
}

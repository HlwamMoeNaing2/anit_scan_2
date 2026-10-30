import 'package:anit_data/anit_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../firebase/firebase_bootstrap.dart';
import 'anit_scan_app.dart';

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

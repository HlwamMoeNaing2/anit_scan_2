import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'firebase_bootstrap.dart';

/// Foreground presentation and the permission prompt belong to the
/// notification feature. This only registers the background entry point.
class PushNotificationService {
  PushNotificationService();

  Future<void> start() async {
    if (Firebase.apps.isEmpty) return;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Push background handler was already registered.');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
}

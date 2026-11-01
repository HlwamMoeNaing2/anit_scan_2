import 'package:core_common/core_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_preferences.dart';
import 'secure_store.dart';

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore(ref.watch(secureStoreProvider));
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw StateError('AppPreferences is created in bootstrap.');
});

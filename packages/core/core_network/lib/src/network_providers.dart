import 'package:core_common/core_common.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'api_config.dart';

final appLoggerProvider = Provider<AppLogger>((ref) => const SilentLogger());

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(apiConfigProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    logger: ref.watch(appLoggerProvider),
  );
  ref.onDispose(client.close);
  return client;
});

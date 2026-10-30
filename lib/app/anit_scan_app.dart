import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_router.dart';
import 'privacy_cover.dart';
import 'theme/app_theme.dart';

class AnitScanApp extends ConsumerWidget {
  const AnitScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Anit Scan 2',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return PrivacyCover(
          enabled: !kDebugMode,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

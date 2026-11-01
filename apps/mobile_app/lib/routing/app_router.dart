import 'package:feature_post/feature_post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_error_page.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'root');
});

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: ref.watch(rootNavigatorKeyProvider),
    initialLocation: AppRoutes.root,
    restorationScopeId: 'app',
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: AppRoutes.rootName,
        builder: (context, state) => const PostsPage(),
      ),
    ],
    errorBuilder: (context, state) => const RouteErrorPage(),
  );
  ref.onDispose(router.dispose);
  return router;
});

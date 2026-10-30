import 'package:flutter/material.dart';

/// Navigation host. The first feature screen replaces this body.
/// Register that route in lib/routing/app_router.dart.
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anit Scan 2')),
      body: const SizedBox.shrink(),
    );
  }
}

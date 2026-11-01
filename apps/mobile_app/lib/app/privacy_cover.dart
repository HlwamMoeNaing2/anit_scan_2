import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android can block screenshots. iOS cannot. Both platforms hide the
/// app-switcher snapshot from [PrivacyCover].
abstract final class ScreenCaptureGuard {
  static const _channel = MethodChannel('com.example.anit_scan_2/security');

  static Future<void> apply({required bool blocked}) async {
    try {
      await _channel.invokeMethod<void>('setScreenCaptureBlocked', {
        'blocked': blocked,
      });
    } on MissingPluginException {
      // Widget tests have no native host.
    } on PlatformException {
      // The engine is not attached yet. Android release already set the flag.
    }
  }
}

class PrivacyCover extends StatefulWidget {
  const PrivacyCover({required this.enabled, required this.child, super.key});

  final bool enabled;
  final Widget child;

  @override
  State<PrivacyCover> createState() => _PrivacyCoverState();
}

class _PrivacyCoverState extends State<PrivacyCover> with WidgetsBindingObserver {
  var _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenCaptureGuard.apply(blocked: widget.enabled);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;
    final covered = switch (state) {
      AppLifecycleState.resumed => false,
      AppLifecycleState.inactive ||
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => true,
    };
    if (covered == _covered) return;
    setState(() => _covered = covered);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_covered)
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFF0E1A2B)),
          ),
      ],
    );
  }
}

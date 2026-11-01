import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.example.anit_scan_2/security",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setScreenCaptureBlocked":
        // iOS does not let an app block screenshots. The Flutter privacy cover
        // hides the app-switcher snapshot. Android uses FLAG_SECURE.
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    let logChannel = FlutterMethodChannel(
      name: "httpsCall",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    logChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "log":
        let message = (call.arguments as? [String: Any])?["message"] as? String ?? ""
        NSLog("httpsCall: %@", message)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

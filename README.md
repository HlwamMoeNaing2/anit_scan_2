# Anit Scan 2

Production shell for the government client. Screens and features are not in this branch. The shell is the app module. Networking and on-device storage are the `anit_data` module. Shared state and error types are `anit_core`.

## Modules

```
lib/                          app module: navigation, view models, composition
  app/                        startup, theme, privacy cover
  di/providers.dart           Riverpod graph. This is the only composition root
  routing/app_router.dart     every route is registered here
  presentation/view_model.dart
  features/                   next branch: one folder per screen
packages/anit_core            UiState, Failure, Result, SessionStore
packages/anit_data            Dio, Drift, secure storage, preferences
```

A screen does not create its own `MaterialApp` or its own `Dio`. The view model calls `launch`, which turns a `Result` into `UiState`.

```dart
class ExampleViewModel extends ViewModel<Example> {
  Future<void> load() {
    return launch(() => guardCall(() => ref.read(repositoryProvider).load()));
  }
}
```

The screen uses `ref.watch(exampleViewModelProvider)` and `state.when(...)`.

## Packages

Riverpod is the dependency injection. A second container such as get_it is not used.

| Need | Package | Why this one |
| --- | --- | --- |
| State and DI | `flutter_riverpod` 3 | Long-maintained, works the same on iOS and Android |
| Navigation | `go_router` | Flutter team package. One route table, named routes |
| HTTP | `dio` | Interceptors, timeouts, certificate pinning. The `http` package is official and too small for this |
| JSON, when DTOs arrive | `json_serializable` | Dart team. Add it with the first response model |
| Secure storage | `flutter_secure_storage` | Android Keystore and iOS Keychain. Not synced to iCloud |
| Ordinary flags | `shared_preferences` | Flutter team. Do not put tokens here |
| Local database | `drift` + `drift_flutter` | Room equivalent: tables, DAO queries, versioned migrations. SQLite ships through the `sqlite3` 3.x native-asset hook, built with NDK r28 |
| Crash reports | `firebase_crashlytics` | Google / FlutterFire. Wired now |
| Push | `firebase_messaging` | Registered only. Permission prompt and notification UI are the next feature |

Drift replaces Room. A Drift table is an `@Entity`, a query on `AppDatabase` is a DAO, and `schemaVersion` plus `migration` are the Room migration. The old `sqlite3_flutter_libs` plugin is an empty end-of-life package that Drift pulls in so the old build path cannot return. Do not add it yourself.

## Platform versions

| | Decision |
| --- | --- |
| Android min | **10 (API 29)**. Android 8 and 9 have had no security updates for years. Use 26 only if a known device is still on Android 8. |
| Android target / compile | **36 (Android 16)**, taken from Flutter 3.47. Do not lower the target. |
| iOS min | **16**. That is iPhone 8 and newer. iOS 15 is out of security support. The app target is set in the Xcode project. |

`com.example.anit_scan_2` and `com.example.anitScan2` are still the template ids. Change both before any store upload.

## Android release build

R8 full mode is on in AGP 9. The release build minifies and optimizes dex with `proguard-android-optimize.txt`, shrinks resources, and keeps line numbers for Crashlytics. Dart code is obfuscated separately:

```sh
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

Keep `build/debug-info` with the store build. It is the map for Dart stack traces. R8 writes its own mapping file, and the Crashlytics Gradle plugin uploads that once `google-services.json` exists.

16 KB pages: NDK r28 aligns native code, and `useLegacyPackaging = false` stores those libraries uncompressed so the package stays zip-aligned. After a release APK:

```sh
sh tool/check_16kb_alignment.sh build/app/outputs/flutter-apk/app-release.apk
```

Baseline profiles are checked in at `android/app/src/main/baselineProfiles/`. `androidx.profileinstaller` installs them on first launch. `startup-prof.txt` is the dex layout file a native app uses to keep startup classes in the primary dex. `android/baselineprofile/StartupBaselineProfile.kt` is the instrumentation test shape. It is not on the Gradle classpath until the first screen exists. Replace the checked-in rules with a device recording at that point.

## iOS

Release builds already compile Swift whole-module at `-O`, strip dead code, and emit a dSYM. Flutter release mode is AOT. There is no baseline-profile file on iOS. That AOT binary is the equivalent. Screenshot blocking is not possible on iOS. The privacy cover hides the app-switcher snapshot in release and profile builds. Android release builds also set `FLAG_SECURE`, which blocks screenshots and screen recording.

App Transport Security does not allow cleartext. Keychain items use `first_unlock_this_device` and are not iCloud-synced. `PrivacyInfo.xcprivacy` declares crash data and UserDefaults (`CA92.1`).

Push needs the Push Notifications capability turned on in Xcode before an App Store upload. The background mode is already in `Info.plist`.

## Firebase

Crashlytics starts when the native config files exist. Until then the app launches and simply does not upload crashes.

```sh
dart pub global activate flutterfire_cli
flutterfire configure
```

Put `google-services.json` in `android/app`. Put `GoogleService-Info.plist` in `ios/Runner` and add it to the Runner target. The Google Services Gradle plugins are applied only when the json file is present, so a machine without Firebase still builds.

Collection is enabled only in release builds. Debug crashes stay off the Firebase console.

`android.builtInKotlin=true` in `android/gradle.properties`. AGP 9 compiles Kotlin. `android/settings.gradle.kts` rewrites the Firebase fallback so Flutter 3.47 does not warn about the Kotlin Gradle Plugin. The fallback still applies that plugin only when the Android Gradle Plugin is older than 9. The same file annotates the deprecated token calls inside `firebase_messaging`, because JDK 17 prints that compiler note even with `-nowarn`. `flutter pub get` restores both plugin copies, and the next Gradle run writes them again.

## Security already in the shell

- Release R8 and Dart obfuscation
- No cleartext, except localhost in debug
- User-installed certificates only while the Android app is debuggable
- Backup and device transfer exclude preferences, database, and files
- Certificate pinning is ready on `ApiConfig.certificateSha256Pins` (lowercase hex SHA-256 of the certificate DER). Leave it empty until the real certificate is known. Empty means the system trust store is used
- HTTP logs, when enabled in debug, record method, path, and status. They do not record query strings or headers
- Server response bodies are not copied into screen error messages

## Useful commands

```sh
flutter pub get
dart test packages/anit_core
flutter test packages/anit_data
flutter test
dart run build_runner build --delete-conflicting-outputs
```

Run `build_runner` from `packages/anit_data` after adding a Drift table.

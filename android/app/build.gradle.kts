plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.anit_scan_2"
    compileSdk = flutter.compileSdkVersion
    // NDK r28+ (Flutter 3.47 ships 28.2) aligns native libraries to 16 KB pages.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.anit_scan_2"
        // Android 10. Android 8 and 9 no longer receive security patches.
        // Drop this to 26 only if a known device fleet is still on Android 8.
        minSdk = 29
        // Flutter 3.47 sets this to 36 (Android 16). Keep the Flutter value so
        // the Play target stays on the current required API.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        jniLibs {
            // Uncompressed native libs are required for 16 KB zip alignment.
            useLegacyPackaging = false
        }
    }

    bundle {
        abi.enableSplit = true
        density.enableSplit = true
        language.enableSplit = true
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            ndk {
                debugSymbolLevel = "FULL"
            }
            // Replace this with the government upload key before a store build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Installs the checked-in baseline profile on first launch, the same
    // library a native app uses when Play has not delivered a cloud profile yet.
    implementation("androidx.profileinstaller:profileinstaller:1.4.1")
}

// Firebase plugins fail the build without google-services.json.
// `flutterfire configure` creates that file. Until then the app still compiles
// and Crashlytics stays disabled.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    id("com.google.gms.google-services") version "4.5.0" apply false
    id("com.google.firebase.crashlytics") version "3.0.8" apply false
}

include(":app")

// Flutter 3.47 flags any Gradle file that contains a line which is only
// `apply plugin: 'kotlin-android'`. firebase_core and firebase_crashlytics
// keep that line inside an if that does not run when android.builtInKotlin is
// true. The same if on one line is not matched, and it still applies KGP only
// for Android Gradle Plugin older than 9.
val flutterPluginDependencies = file("../.flutter-plugins-dependencies")
if (flutterPluginDependencies.exists()) {
    val pluginPaths =
        Regex(""""name"\s*:\s*"(?:firebase_core|firebase_crashlytics)"\s*,\s*"path"\s*:\s*"([^"]+)"""")
            .findAll(flutterPluginDependencies.readText())
            .map { it.groupValues[1].replace("\\/", "/").replace("\\\\", "\\") }
            .toSet()
    val multilineKgpFallback =
        Regex(
            """(?m)^([ \t]*)if\s*\(\s*agpMajor\s*<\s*9\s*\|\|\s*!builtInKotlin\s*\)\s*\{\s*\r?\n[ \t]*apply\s+plugin:\s*'kotlin-android'\s*\r?\n\1\}""",
        )
    for (pluginPath in pluginPaths) {
        val pluginBuild = file("$pluginPath/android/build.gradle")
        if (!pluginBuild.isFile) continue
        val original = pluginBuild.readText()
        val updated =
            multilineKgpFallback.replace(original) { match ->
                "${match.groupValues[1]}if (agpMajor < 9 || !builtInKotlin) apply plugin: 'kotlin-android'"
            }
        if (updated != original) {
            pluginBuild.writeText(updated)
        }
    }

    // JDK 17 prints "Some input files use or override a deprecated API" as a
    // mandatory note. -Xlint:-deprecation and -nowarn do not hide it.
    // firebase_messaging 17.0.1 still calls deprecated token APIs. Annotating
    // those methods removes the note. pub get restores the files; this runs again.
    val messagingPaths =
        Regex(""""name"\s*:\s*"firebase_messaging"\s*,\s*"path"\s*:\s*"([^"]+)"""")
            .findAll(flutterPluginDependencies.readText())
            .map { it.groupValues[1].replace("\\/", "/").replace("\\\\", "\\") }
            .toSet()
    val messagingSources =
        listOf(
            "android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingService.java" to
                listOf("  public void onNewToken(@NonNull String token) {"),
            "android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingPlugin.java" to
                listOf(
                    "  private Task<Void> deleteToken() {",
                    "  private Task<Map<String, Object>> getToken() {",
                ),
        )
    for (pluginPath in messagingPaths) {
        for ((relativePath, signatures) in messagingSources) {
            val source = file("$pluginPath/$relativePath")
            if (!source.isFile) continue
            var text = source.readText()
            var changed = false
            for (signature in signatures) {
                val indent = signature.takeWhile { it == ' ' }
                val annotated = "$indent@SuppressWarnings(\"deprecation\")\n$signature"
                if (text.contains(annotated) || !text.contains(signature)) continue
                text = text.replace(signature, annotated)
                changed = true
            }
            if (changed) source.writeText(text)
        }
    }
}

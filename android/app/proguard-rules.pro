# Flutter embedding. R8 keeps these because the engine is called from JNI
# and from the generated plugin registrant.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Crashlytics needs line numbers to match the R8 mapping file.
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Play Core is optional. Flutter's deferred components reference it.
-dontwarn com.google.android.play.core.**

# Secure storage and Firebase use reflection on some AndroidX types.
-keep class androidx.security.** { *; }
-dontwarn androidx.security.**

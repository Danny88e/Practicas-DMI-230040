# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-dontwarn io.flutter.embedding.**

# Play Core rules
-dontwarn com.google.android.play.core.**

# Isar DB rules
-keep class io.isar.** { *; }
-dontwarn io.isar.**

# InAppWebView rules
-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview_android.**

# General fallback for optional dependencies
-dontwarn **

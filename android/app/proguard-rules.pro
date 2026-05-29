# =============================================================================
# ProGuard / R8 keep rules
#
# Release builds run R8 (isMinifyEnabled = true). Debug builds do not — which is
# why scheduled notifications fire in debug but silently fail in release.
#
# flutter_local_notifications persists every scheduled notification to disk as
# JSON via Gson, then a background receiver (ScheduledNotificationReceiver /
# ScheduledNotificationBootReceiver) deserializes it when the AlarmManager alarm
# fires and after device reboot. R8 full mode (the AGP 8+ default) obfuscates
# those model classes and strips the generic type signatures Gson relies on, so
# deserialization returns null and the notification never posts.
#
# These rules keep the plugin classes, Gson, and the attributes Gson needs.
# =============================================================================

# ---- flutter_local_notifications -------------------------------------------
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# ---- Gson -------------------------------------------------------------------
# Generic signatures + annotations must survive or Gson's TypeToken reflection
# breaks under R8 full mode.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations

-keep class com.google.gson.** { *; }

# Keep fields annotated for serialization (don't rename them).
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# R8 full mode strips TypeToken's generic type argument — keep it explicitly.
-keep class com.google.gson.reflect.TypeToken { *; }
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ---- Flutter (standard) -----------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

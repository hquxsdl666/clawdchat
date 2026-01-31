# ProGuard rules
# Keep model classes for serialization
-keepclassmembers class com.clawd.chat.data.model.** {
    *;
}

# Keep Hilt components
-keep class dagger.hilt.** { *; }

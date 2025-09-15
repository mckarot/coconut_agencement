# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase Core
-keep class com.google.firebase.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# Cloud Functions
-keep class com.google.firebase.functions.** { *; }

# Cloud Storage
-keep class com.google.firebase.storage.** { *; }

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# App Check
-keep class com.google.firebase.appcheck.** { *; }

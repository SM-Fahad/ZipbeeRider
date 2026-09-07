# Stripe Push Provisioning rules
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }

# Google Play Core rules (Deferred Components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Flutter handles these usually, but adding for safety
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Stripe SDK - Keep all Stripe classes
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Stripe Push Provisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Firebase related
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum constants
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Flutter specific
-keep class io.flutter.** { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Google Maps & Google Navigation SDK
-keep class com.google.android.libraries.navigation.** { *; }
-dontwarn com.google.android.libraries.navigation.**

-keep class com.google.android.libraries.maps.** { *; }
-dontwarn com.google.android.libraries.maps.**

-keep class com.google.android.libraries.geo.** { *; }
-dontwarn com.google.android.libraries.geo.**

-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**



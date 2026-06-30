# AppLovin MAX
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**

# AdMob mediation
-keep class com.google.android.gms.ads.** { *; }

# Meta mediation
-keep class com.facebook.ads.** { *; }

# Unity mediation
-keep class com.unity3d.ads.** { *; }

# ironSource mediation
-keep class com.ironsource.** { *; }
-dontwarn com.ironsource.**

# Hive
-keep class com.hive.** { *; }
-keep class * extends com.hive.typeadapter.TypeAdapter { *; }

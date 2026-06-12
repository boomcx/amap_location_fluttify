# 系统Application 关键：解决 android.app.Application::get 反射找不到
-keep class android.app.Application { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter 核心保留
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.lifecycle.** { *; }

# fluttify 全套强制保留（核心报错通道）
-keep class com.fluttify.** { *; }
-keep interface com.fluttify.** { *; }
-keep class * implements com.fluttify.** { *; }
-keep class * extends com.fluttify.** { *; }

# 高德定位/地图 SDK
-keep class com.amap.api.** {*;}
-keep class com.amap.api.maps.** {*;}
-keep class com.autonavi.** {*;}
-keep class com.loc.**{*;}
-dontwarn com.amap.api.**
-dontwarn com.autonavi.**

# 屏蔽 Google Play 拆分库警告
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# 通用反射、方法保留规则
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
# حماية كلاسات الموديلات عشان الـ JSON ميبوظش
-keep class com.example.graduation_project.features.**.models.** { *; }

# حماية مكتبات جوجل وفايبربيز والإشعارات
-keep class com.google.gson.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep enum com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.llfbandit.app_links.** { *; }

# حماية مكتبة الصوت
-keep class xyz.luan.audioplayers.** { *; }
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class TimeZoneHelper {
//   // دالة تهيئة (يجب استدعاؤها في main.dart قبل runApp)
//   static void init() {
//     tz.initializeTimeZones();
//   }

//   static String getCurrentTimeZone() {
//     try {
//       // محاولة جلب التوقيت المحلي
//       final locationName = tz.local.name;
      
//       // معالجة الحالات الخاصة لضمان التوافق مع IANA TimeZone Database
//       if (locationName == "Egypt Standard Time" || locationName == "EET") {
//         return "Africa/Cairo";
//       } else if (locationName == "Arabian Standard Time") {
//         return "Asia/Riyadh";
//       } else if (locationName == "Arab Standard Time") {
//         return "Asia/Dubai";
//       }
      
//       return locationName;
//     } catch (e) {
//       // القيمة الافتراضية في حالة الخطأ
//       return "Africa/Cairo";
//     }
//   }
// }
import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneHelper {
  
  /// دالة لجلب الـ TimeZone ID الخاص بالجهاز
  static Future<String> getCurrentTimeZone() async {
    try {
      // هذه المكتبة تجلب التوقيت بدقة (مثل Africa/Cairo مباشرة)
      final String currentTimeZone = (await FlutterTimezone.getLocalTimezone()) as String;
      return currentTimeZone;
    } catch (e) {
      // في حالة حدوث أي خطأ، نعود للتوقيت الافتراضي (مصر)
      return "Africa/Cairo";
    }
  }
}
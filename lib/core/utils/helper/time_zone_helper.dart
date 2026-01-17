import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneHelper {
  static Future<String> getCurrentTimeZone() async {
    try {
      final String currentTimeZone =
          (await FlutterTimezone.getLocalTimezone()) as String;
      return currentTimeZone;
    } catch (e) {
      return "Africa/Cairo";
    }
  }
}

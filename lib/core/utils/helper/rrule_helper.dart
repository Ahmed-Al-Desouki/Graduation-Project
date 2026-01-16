import 'package:rrule/rrule.dart';

/// ✅ Helper class للتعامل مع RRULE - متوافق 100% مع rrule ^0.2.17
class RRuleHelper {
  // ==================== CONVERSION ====================

  /// تحويل RRULE string لـ RecurrenceRule object
  // static RecurrenceRule? fromString(String? rruleString) {
  //   if (rruleString == null || rruleString.isEmpty) return null;
  //   try {
  //     return RecurrenceRule.fromString(rruleString);
  //   } catch (e) {
  //     print("❌ Invalid RRULE: $e");
  //     return null;
  //   }
  // }
  static RecurrenceRule? fromString(String? rruleString) {
    if (rruleString == null || rruleString.isEmpty) return null;
    try {
      String cleanRule = rruleString;

      // إزالة DTSTART وأي أسطر إضافية
      if (cleanRule.contains('RRULE:')) {
        cleanRule = cleanRule.split('RRULE:').last.trim();
      } else if (cleanRule.contains('\n')) {
        cleanRule = cleanRule.split('\n').last.trim();
      }

      // تنظيف التاريخ في UNTIL (إزالة - و :)
      if (cleanRule.contains('UNTIL=')) {
        final untilRegex = RegExp(
          r'UNTIL=(\d{4})-?(\d{2})-?(\d{2})T?(\d{2}):?(\d{2}):?(\d{2})Z?',
        );
        cleanRule = cleanRule.replaceAllMapped(untilRegex, (m) {
          return "UNTIL=${m[1]}${m[2]}${m[3]}T${m[4]}${m[5]}${m[6]}Z";
        });
      }

      return RecurrenceRule.fromString(cleanRule);
    } catch (e) {
      // نرجع null بدل ما يضرب الأبلكيشن، والـ Regex اللي فوق هيقوم بالواجب في الـ Edit
      print(
        "⚠️ Warning: RRule parser skipped, using Regex fallback. Error: $e",
      );
      return null;
    }
  }

  // static String _fixUntilFormat(String rule) {
  //   return rule.replaceAllMapped(RegExp(r'UNTIL=([^;]+)'), (match) {
  //     String datePart = match.group(1)!;
  //     String fixedDate = datePart.replaceAll('-', '').replaceAll(':', '');
  //     return 'UNTIL=$fixedDate';
  //   });
  // }

  /// التحقق من صحة الـ RRULE
  static bool isValid(String? rruleString) {
    return fromString(rruleString) != null;
  }

  // ==================== BUILDERS (String-based) ====================

  /// بناء RRULE يومي (بدون استخدام constructor parameters الناقصة)
  static String buildDaily({
    required List<int> hours,    // تم التغيير لـ List
    required List<int> minutes,
    DateTime? until,
  }) {
    final hoursStr = hours.join(',');
    final minutesStr = minutes.join(',');
    String rrule = "FREQ=DAILY;BYHOUR=$hoursStr;BYMINUTE=$minutesStr";

    // if (until != null) {
    //   final untilUtc = until.toUtc();
    //   rrule += ";UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    // }
    if (until != null) {
      final untilUtc = until.toUtc();
      // التعديل هنا: إزالة الفواصل والشرطات
      final formattedUntil = untilUtc
          .toIso8601String()
          .split('.')
          .first
          .replaceAll('-', '')
          .replaceAll(':', '');
      rrule += ";UNTIL=$formattedUntil";
    }

    return rrule;
  }

  /// بناء RRULE أسبوعي
  static String buildWeekly({
    required Set<int> weekDays, // DateTime.monday, etc.
    required List<int> hours,    // تم التغيير لـ List
    required List<int> minutes,
    DateTime? until,
  }) {
    // تحويل أرقام الأيام إلى رموز RRULE
    final daysMap = {
      DateTime.monday: 'MO',
      DateTime.tuesday: 'TU',
      DateTime.wednesday: 'WE',
      DateTime.thursday: 'TH',
      DateTime.friday: 'FR',
      DateTime.saturday: 'SA',
      DateTime.sunday: 'SU',
    };

    final selectedDaysStr = weekDays
        .map((day) => daysMap[day])
        .where((d) => d != null)
        .join(',');

    final hoursStr = hours.join(',');
    final minutesStr = minutes.join(',');
    String rrule =
        "FREQ=WEEKLY;BYDAY=$selectedDaysStr;BYHOUR=$hoursStr;BYMINUTE=$minutesStr";

    // if (until != null) {
    //   final untilUtc = until.toUtc();
    //   rrule += ";UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    // }
    if (until != null) {
      final untilUtc = until.toUtc();
      // التعديل هنا: إزالة الفواصل والشرطات
      final formattedUntil = untilUtc
          .toIso8601String()
          .split('.')
          .first
          .replaceAll('-', '')
          .replaceAll(':', '');
      rrule += ";UNTIL=$formattedUntil";
    }

    return rrule;
  }

  /// بناء RRULE شهري
  static String buildMonthly({
    required int monthDay, // 1-31
    required List<int> hours,    // تم التغيير لـ List
    required List<int> minutes,
    DateTime? until,
  }) {
    final hoursStr = hours.join(',');
    final minutesStr = minutes.join(',');
    String rrule =
        "FREQ=MONTHLY;BYMONTHDAY=$monthDay;BYHOUR=$hoursStr;BYMINUTE=$minutesStr";

    // if (until != null) {
    //   final untilUtc = until.toUtc();
    //   rrule += ";UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    // }
    if (until != null) {
      final untilUtc = until.toUtc();
      // التعديل هنا: إزالة الفواصل والشرطات
      final formattedUntil = untilUtc
          .toIso8601String()
          .split('.')
          .first
          .replaceAll('-', '')
          .replaceAll(':', '');
      rrule += ";UNTIL=$formattedUntil";
    }

    return rrule;
  }

  /// بناء RRULE ساعي (Hourly)
  static String buildHourly({required int interval, DateTime? until}) {
    String rrule = "FREQ=HOURLY;INTERVAL=$interval";

    // if (until != null) {
    //   final untilUtc = until.toUtc();
    //   rrule += ";UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    // }
    if (until != null) {
      final untilUtc = until.toUtc();
      // التعديل هنا: إزالة الفواصل والشرطات
      final formattedUntil = untilUtc
          .toIso8601String()
          .split('.')
          .first
          .replaceAll('-', '')
          .replaceAll(':', '');
      rrule += ";UNTIL=$formattedUntil";
    }

    return rrule;
  }

  /// بناء RRULE سنوي
  static String buildYearly({
    required int month,
    required int day,
    required int hour,
    required int minute,
    DateTime? until,
  }) {
    String rrule =
        "FREQ=YEARLY;BYMONTH=$month;BYMONTHDAY=$day;BYHOUR=$hour;BYMINUTE=$minute";

    // if (until != null) {
    //   final untilUtc = until.toUtc();
    //   rrule += ";UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    // }
    if (until != null) {
      final untilUtc = until.toUtc();
      // التعديل هنا: إزالة الفواصل والشرطات
      final formattedUntil = untilUtc
          .toIso8601String()
          .split('.')
          .first
          .replaceAll('-', '')
          .replaceAll(':', '');
      rrule += ";UNTIL=$formattedUntil";
    }

    return rrule;
  }

  // ==================== INSTANCES ====================

  /// حساب التكرارات في فترة معينة
  static List<DateTime> getInstances(
    String rruleString, {
    required DateTime start,
    DateTime? until,
    int limit = 50,
  }) {
    final rrule = fromString(rruleString);
    if (rrule == null) return [];

    try {
      final instances = rrule.getInstances(start: start.copyWith(isUtc: true));
      return instances
          .take(limit)
          .where((d) => until == null || d.isBefore(until))
          .map((d) => d.copyWith(isUtc: false))
          .toList();
    } catch (e) {
      print("❌ Error getting instances: $e");
      return [];
    }
  }

  /// الحصول على أول X تكرارات
  static List<DateTime> getFirstOccurrences({
    required String rruleString,
    required DateTime start,
    int count = 5,
  }) {
    final rrule = fromString(rruleString);
    if (rrule == null) return [];

    try {
      final instances = rrule.getInstances(start: start.copyWith(isUtc: true));
      return instances
          .take(count)
          .map((dt) => dt.copyWith(isUtc: false))
          .toList();
    } catch (e) {
      print("❌ Error getting occurrences: $e");
      return [];
    }
  }

  // ==================== TEXT CONVERSION ====================

  /// توليد نص مقروء من RRULE
  static Future<String> toHumanReadable(String rruleString) async {
    final rrule = fromString(rruleString);
    if (rrule == null) return "Invalid recurrence rule";

    try {
      final l10n = await RruleL10nEn.create();
      return rrule.toText(l10n: l10n);
    } catch (e) {
      return _getBasicDescription(rrule);
    }
  }

  /// وصف أساسي للـ RRULE (fallback)
  static String _getBasicDescription(RecurrenceRule rrule) {
    switch (rrule.frequency) {
      case Frequency.daily:
        return "Daily";
      case Frequency.weekly:
        return "Weekly";
      case Frequency.monthly:
        return "Monthly";
      case Frequency.yearly:
        return "Yearly";
      case Frequency.hourly:
        return "Every ${rrule.interval} hour(s)";
      default:
        return "Custom recurrence";
    }
  }

  // ==================== EXTRACTORS ====================

  /// استخراج التردد من RRULE
  static String getFrequency(String rruleString) {
    final rrule = fromString(rruleString);
    if (rrule == null) return "Unknown";
    // UNTIL=2026-01-10T21:59:59Z
    // UNTIL=20260110T215959Z
    switch (rrule.frequency) {
      case Frequency.daily:
        return "Daily";
      case Frequency.weekly:
        return "Weekly";
      case Frequency.monthly:
        return "Monthly";
      case Frequency.yearly:
        return "Yearly";
      case Frequency.hourly:
        return "Hourly";
      case Frequency.minutely:
        return "Every Minute";
      case Frequency.secondly:
        return "Every Second";
      default:
        return "Custom";
    }
  }

  /// استخراج الأيام من RRULE أسبوعي (من الـ string مباشرة)
  static Set<int>? getWeekDays(String rruleString) {
    try {
      final bydayMatch = RegExp(r'BYDAY=([^;]+)').firstMatch(rruleString);
      if (bydayMatch != null) {
        final daysString = bydayMatch.group(1);
        final daysCodes = daysString?.split(',') ?? [];

        final daysMap = {
          'MO': DateTime.monday,
          'TU': DateTime.tuesday,
          'WE': DateTime.wednesday,
          'TH': DateTime.thursday,
          'FR': DateTime.friday,
          'SA': DateTime.saturday,
          'SU': DateTime.sunday,
        };

        return daysCodes
            .map((code) => daysMap[code.toUpperCase()])
            .where((day) => day != null)
            .cast<int>()
            .toSet();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// استخراج أيام الشهر من RRULE شهري (من الـ string مباشرة)
  static Set<int>? getMonthDays(String rruleString) {
    try {
      final match = RegExp(r'BYMONTHDAY=([^;]+)').firstMatch(rruleString);
      if (match != null) {
        final daysString = match.group(1);
        return daysString
            ?.split(',')
            .map((d) => int.tryParse(d))
            .where((d) => d != null)
            .cast<int>()
            .toSet();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// استخراج الساعة من RRULE
  // static int? getHour(String rruleString) {
  //   final match = RegExp(r'BYHOUR=(\d+)').firstMatch(rruleString);
  //   return match != null ? int.tryParse(match.group(1)!) : null;
  // }

  // /// استخراج الدقيقة من RRULE
  // static int? getMinute(String rruleString) {
  //   final match = RegExp(r'BYMINUTE=(\d+)').firstMatch(rruleString);
  //   return match != null ? int.tryParse(match.group(1)!) : null;
  // }

  static List<int> getHours(String rruleString) { // تغير الاسم لـ getHours
    final match = RegExp(r'BYHOUR=([\d,]+)').firstMatch(rruleString);
    if (match != null) {
      return match.group(1)!.split(',').map(int.parse).toList();
    }
    return [];
  }

  static List<int> getMinutes(String rruleString) { // تغير الاسم لـ getMinutes
    final match = RegExp(r'BYMINUTE=([\d,]+)').firstMatch(rruleString);
    if (match != null) {
      return match.group(1)!.split(',').map(int.parse).toList();
    }
    return [];
  }

  /// استخراج الـ interval
  static int? getInterval(String rruleString) {
    final match = RegExp(r'INTERVAL=(\d+)').firstMatch(rruleString);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    final rrule = fromString(rruleString);
    return rrule?.interval;
  }

  /// التحقق من وجود UNTIL
  static bool hasUntil(String rruleString) {
    return rruleString.contains('UNTIL');
  }

  /// استخراج UNTIL date
  static DateTime? getUntil(String rruleString) {
    final rrule = fromString(rruleString);
    return rrule?.until;
  }

  // ==================== MODIFIERS ====================

  /// إضافة UNTIL إلى RRULE موجود
  static String addUntil(String rruleString, DateTime until) {
    if (hasUntil(rruleString)) {
      final parts = rruleString.split(';');
      final withoutUntil = parts.where((p) => !p.startsWith('UNTIL')).join(';');
      final untilUtc = until.toUtc();
      return "$withoutUntil;UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    } else {
      final untilUtc = until.toUtc();
      return "$rruleString;UNTIL=${untilUtc.toIso8601String().split('.').first}Z";
    }
  }

  /// إضافة BYHOUR و BYMINUTE يدويًا
  static String addTime(String rruleString, int hour, int minute) {
    String result = rruleString;

    if (!result.contains('BYHOUR')) {
      result += ';BYHOUR=$hour';
    }
    if (!result.contains('BYMINUTE')) {
      result += ';BYMINUTE=$minute';
    }

    return result;
  }

  // ==================== HELPERS ====================

  /// تحويل رقم اليوم إلى اسم
  static String dayNumberToName(int dayNumber) {
    switch (dayNumber) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// تحويل رقم اليوم إلى رمز RRULE
  static String dayNumberToRRuleCode(int dayNumber) {
    switch (dayNumber) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        return 'MO';
    }
  }

  /// تحويل رمز RRULE إلى رقم اليوم
  static int rruleCodeToDayNumber(String code) {
    switch (code.toUpperCase()) {
      case 'MO':
        return DateTime.monday;
      case 'TU':
        return DateTime.tuesday;
      case 'WE':
        return DateTime.wednesday;
      case 'TH':
        return DateTime.thursday;
      case 'FR':
        return DateTime.friday;
      case 'SA':
        return DateTime.saturday;
      case 'SU':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  // ==================== DEBUGGING ====================

  /// طباعة معلومات RRULE للـ Debugging
  static void debugPrint(String rruleString) {
    print("📅 ===== RRULE DEBUG INFO =====");
    print("Full RRULE: $rruleString");
    print("Frequency: ${getFrequency(rruleString)}");
    print("Interval: ${getInterval(rruleString)}");
    print("Until: ${getUntil(rruleString)}");
    print("Week Days: ${getWeekDays(rruleString)}");
    print("Month Days: ${getMonthDays(rruleString)}");
    print("Hour: ${getHours(rruleString)}");
    print("Minute: ${getMinutes(rruleString)}");
    print("Valid: ${isValid(rruleString)}");
    print("=============================");
  }

  /// مثال على الاستخدام
  static void exampleUsage() {
    print("\n🔧 === RRULE Helper Examples ===\n");

    // Daily at 9:00 AM
    final dailyRRule = buildDaily(
      hours: [9],
      minutes: [0],
      until: DateTime(2025, 12, 31),
    );
    print("1️⃣ Daily RRULE: $dailyRRule");

    // Weekly on Monday and Wednesday at 2:30 PM
    final weeklyRRule = buildWeekly(
      weekDays: {DateTime.monday, DateTime.wednesday},
      hours: [14],
      minutes: [30],
      until: DateTime(2025, 12, 31),
    );
    print("2️⃣ Weekly RRULE: $weeklyRRule");

    // Monthly on 1st at 10:00 AM
    final monthlyRRule = buildMonthly(
      monthDay: 1,
      hours: [10],
      minutes: [0],
      until: DateTime(2025, 12, 31),
    );
    print("3️⃣ Monthly RRULE: $monthlyRRule");

    // Every 6 hours
    final hourlyRRule = buildHourly(interval: 6, until: DateTime(2025, 12, 31));
    print("4️⃣ Hourly RRULE: $hourlyRRule");

    // Debug
    print("\n📊 Debugging Daily RRULE:");
    debugPrint(dailyRRule);

    // Get first 5 occurrences
    print("\n📆 First 5 occurrences:");
    final occurrences = getFirstOccurrences(
      rruleString: dailyRRule,
      start: DateTime.now(),
      count: 5,
    );
    for (var i = 0; i < occurrences.length; i++) {
      print("  ${i + 1}. ${occurrences[i]}");
    }

    print("\n✅ === Examples Complete ===\n");
  }
}

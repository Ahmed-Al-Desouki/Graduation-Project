import 'dart:developer';

import 'package:rrule/rrule.dart';

class RRuleHelper {
  static RecurrenceRule? fromString(String? rruleString) {
    if (rruleString == null || rruleString.isEmpty) return null;
    try {
      String cleanRule = rruleString;

      if (cleanRule.contains('RRULE:')) {
        cleanRule = cleanRule.split('RRULE:').last.trim();
      } else if (cleanRule.contains('\n')) {
        cleanRule = cleanRule.split('\n').last.trim();
      }

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
      log("⚠️ Warning: RRule parser skipped, using Regex fallback. Error: $e");
      return null;
    }
  }

  static bool isValid(String? rruleString) {
    return fromString(rruleString) != null;
  }

  static String buildDaily({
    required List<int> hours,
    required List<int> minutes,
    DateTime? until,
  }) {
    final hoursStr = hours.join(',');
    final minutesStr = minutes.join(',');
    String rrule = "FREQ=DAILY;BYHOUR=$hoursStr;BYMINUTE=$minutesStr";

    if (until != null) {
      final untilUtc = until.toUtc();

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

  static String buildWeekly({
    required Set<int> weekDays,
    required List<int> hours,
    required List<int> minutes,
    DateTime? until,
  }) {
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

    if (until != null) {
      final untilUtc = until.toUtc();

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

  static String buildMonthly({
    required int monthDay,
    required List<int> hours,
    required List<int> minutes,
    DateTime? until,
  }) {
    final hoursStr = hours.join(',');
    final minutesStr = minutes.join(',');
    String rrule =
        "FREQ=MONTHLY;BYMONTHDAY=$monthDay;BYHOUR=$hoursStr;BYMINUTE=$minutesStr";

    if (until != null) {
      final untilUtc = until.toUtc();

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

  static String buildHourly({required int interval, DateTime? until}) {
    String rrule = "FREQ=HOURLY;INTERVAL=$interval";

    if (until != null) {
      final untilUtc = until.toUtc();

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

  static String buildYearly({
    required int month,
    required int day,
    required int hour,
    required int minute,
    DateTime? until,
  }) {
    String rrule =
        "FREQ=YEARLY;BYMONTH=$month;BYMONTHDAY=$day;BYHOUR=$hour;BYMINUTE=$minute";

    if (until != null) {
      final untilUtc = until.toUtc();

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
      log("❌ Error getting instances: $e");
      return [];
    }
  }

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
      log("❌ Error getting occurrences: $e");
      return [];
    }
  }

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

  static String getFrequency(String rruleString) {
    final rrule = fromString(rruleString);
    if (rrule == null) return "Unknown";

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

  static List<int> getHours(String rruleString) {
    final match = RegExp(r'BYHOUR=([\d,]+)').firstMatch(rruleString);
    if (match != null) {
      return match.group(1)!.split(',').map(int.parse).toList();
    }
    return [];
  }

  static List<int> getMinutes(String rruleString) {
    final match = RegExp(r'BYMINUTE=([\d,]+)').firstMatch(rruleString);
    if (match != null) {
      return match.group(1)!.split(',').map(int.parse).toList();
    }
    return [];
  }

  static int? getInterval(String rruleString) {
    final match = RegExp(r'INTERVAL=(\d+)').firstMatch(rruleString);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    final rrule = fromString(rruleString);
    return rrule?.interval;
  }

  static bool hasUntil(String rruleString) {
    return rruleString.contains('UNTIL');
  }

  static DateTime? getUntil(String rruleString) {
    final rrule = fromString(rruleString);
    return rrule?.until;
  }

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

  static void debuglog(String rruleString) {
    log("📅 ===== RRULE DEBUG INFO =====");
    log("Full RRULE: $rruleString");
    log("Frequency: ${getFrequency(rruleString)}");
    log("Interval: ${getInterval(rruleString)}");
    log("Until: ${getUntil(rruleString)}");
    log("Week Days: ${getWeekDays(rruleString)}");
    log("Month Days: ${getMonthDays(rruleString)}");
    log("Hour: ${getHours(rruleString)}");
    log("Minute: ${getMinutes(rruleString)}");
    log("Valid: ${isValid(rruleString)}");
    log("=============================");
  }

  static void exampleUsage() {
    log("\n🔧 === RRULE Helper Examples ===\n");

    final dailyRRule = buildDaily(
      hours: [9],
      minutes: [0],
      until: DateTime(2025, 12, 31),
    );
    log("1️⃣ Daily RRULE: $dailyRRule");

    final weeklyRRule = buildWeekly(
      weekDays: {DateTime.monday, DateTime.wednesday},
      hours: [14],
      minutes: [30],
      until: DateTime(2025, 12, 31),
    );
    log("2️⃣ Weekly RRULE: $weeklyRRule");

    final monthlyRRule = buildMonthly(
      monthDay: 1,
      hours: [10],
      minutes: [0],
      until: DateTime(2025, 12, 31),
    );
    log("3️⃣ Monthly RRULE: $monthlyRRule");

    final hourlyRRule = buildHourly(interval: 6, until: DateTime(2025, 12, 31));
    log("4️⃣ Hourly RRULE: $hourlyRRule");

    log("\n📊 Debugging Daily RRULE:");
    debuglog(dailyRRule);

    log("\n📆 First 5 occurrences:");
    final occurrences = getFirstOccurrences(
      rruleString: dailyRRule,
      start: DateTime.now(),
      count: 5,
    );
    for (var i = 0; i < occurrences.length; i++) {
      log("  ${i + 1}. ${occurrences[i]}");
    }

    log("\n✅ === Examples Complete ===\n");
  }
}

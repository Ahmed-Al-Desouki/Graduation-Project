import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/time_zone_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

class ReminderWebService {
  final ApiService _apiService;

  ReminderWebService(this._apiService);

  Future<ReminderModel> createReminder(
    String patientId, {
    required String type,
    required String title,
    required DateTime startDate, // ← DateTime
    required DateTime endDate,
    String? rrule, // ← جديد
    SimpleModel? simple,
    required String message,
  }) async {
    final String timeZone = await TimeZoneHelper.getCurrentTimeZone();
    print("Detected TimeZone: $timeZone");

    final Map<String, dynamic> body = {
      "type": type,
      "title": title,
      "message": message.isEmpty ? null : message,
      "startDate": startDate.toIso8601String().split('.').first,
      "endDate": endDate.toIso8601String().split('.').first,
      "timeZoneId": timeZone,
    };

    if (rrule != null && rrule.isNotEmpty) {
      body["rrule"] = rrule;
    } else if (simple != null) {
      body["simple"] = simple.toJson();
    }

    final response = await _apiService.post(
      "v2/patients/$patientId/reminders",
      body,
    );

    print("Raw response from server: $response"); // مهم جدًا نشوف إيه اللي راجع

    // الـ Backend بتاعك بيرجع الـ Reminder كامل في الـ response مباشرة
    // أو بيرجع { "data": { ... } } أو حتى بيرجع null
    dynamic data = response;

    // لو رجع { "data": { ... } }
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      data = response['data'];
    }

    // لو رجع الـ Reminder مباشرة (مش داخل data)
    if (data is Map<String, dynamic>) {
      return ReminderModel.fromJson(data);
    }

    // لو مفيش data خالص (بس الـ status 201) → نرجع Reminder فارغ بس ناجح
    return ReminderModel(
      type: type,
      title: title,
      startDate: startDate,
      endDate: endDate,
      patientID: int.parse(patientId),
      rrule: rrule,
      simple: simple,
    );
  }

  // 💡 إضافة دالة Get Today Reminders (V2)
  Future<List<ReminderInstanceModel>> getTodayReminders(
    String patientId,
  ) async {
    final response = await _apiService.get(
      "v2/patients/$patientId/reminders/today", // ✅ V2 Endpoint
    );
    print("Response received: $response");
    if (response is List) {
      return response.map((e) => ReminderInstanceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<ReminderModel> updateReminder(
    String patientId,
    String reminderId, {
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  }) async {
    final body = {
      "name": name,
      "startDate": startDate,
      "endDate": endDate,
      "frequency": frequency,
      "intervalHours": intervalHours,
      "baseTime": baseTime,
      "message": message,
    };
    final response = await _apiService.put(
      "v2/patients/$patientId/reminders/$reminderId",
      body,
    );
    if (response is Map<String, dynamic>) {
      return ReminderModel.fromJson(response); // ✅ يجب تحويلها
    } else {
      throw Exception("Invalid response format received for Update.");
    }
  }

  // Future<void> deleteReminder({
  //   required String patientId,
  //   required String reminderId,
  // }) async {
  //   await _apiService.delete(
  //     "patients/$patientId/reminders/$reminderId",
  //   );
  // }

  // 💡 تعديل Delete Reminder (V2)
  Future<void> deleteReminder({
    required String patientId,
    required String reminderId,
  }) async {
    await _apiService.delete(
      "v2/patients/$patientId/reminders/$reminderId", // ✅ V2 Endpoint
    );
  }

  // داخل ملف reminder_web_service.dart
  Future<List<ReminderInstanceModel>> getUpcomingReminders(
    String patientId, {
    int days = 14,
  }) async {
    final response = await _apiService.get(
      "v2/patients/$patientId/reminders/upcoming?days=$days",
    );
    if (response is List) {
      return response.map((e) => ReminderInstanceModel.fromJson(e)).toList();
    }
    return [];
  }

  // داخل ملف reminder_web_service.dart

  // 1. تأكيد أخذ الدواء (Confirm/Taken) [cite: 72, 73]
  Future<void> confirmOccurrence({
    required int reminderId,
    required String occurrenceDateTime, // LOCAL [cite: 74, 96]
  }) async {
    await _apiService.post("v2/occurrences/confirm", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 2, // Taken [cite: 35, 140]
    });
  }

  // 2. طلب غفوة (Snooze) [cite: 76, 77]
  Future<void> snoozeOccurrence({
    required int reminderId,
    required String occurrenceDateTime,
    int minutes = 15, // الافتراضي حسب التوثيق [cite: 77]
  }) async {
    await _apiService.post("v2/occurrences/snooze?minutes=$minutes", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 4, // Snoozed [cite: 37, 140]
    });
  }

  // 3. تخطي الموعد (Skip) [cite: 80, 81]
  Future<void> skipOccurrence({
    required int reminderId,
    required String occurrenceDateTime,
  }) async {
    await _apiService.post("v2/occurrences/skip", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 3, // Skipped [cite: 35, 140]
    });
  }
}

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
    required DateTime startDate,
    required DateTime? endDate,
    String? rrule,
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
      "endDate": endDate?.toIso8601String().split('.').first,
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

    print("Raw response from server: $response");
    dynamic data = response;

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      data = response['data'];
    }

    if (data is Map<String, dynamic>) {
      return ReminderModel.fromJson(data);
    }

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

  Future<List<ReminderModel>> getAllReminders(String patientId) async {
    final response = await _apiService.get("v2/patients/$patientId/reminders");

    print("All Reminders Response: $response");

    if (response is List) {
      return response.map((e) => ReminderModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ReminderInstanceModel>> getTodayReminders(
    String patientId,
  ) async {
    final response = await _apiService.get(
      "v2/patients/$patientId/reminders/today",
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
    required String title,
    required dynamic startDate,
    required dynamic endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
    required bool isSimpleEveryXHours,
  }) async {
    final Map<String, dynamic> data = {
      "title": title,
      "startDate":
          startDate is DateTime ? startDate.toIso8601String() : startDate,
      "endDate": endDate is DateTime ? endDate.toIso8601String() : endDate,
      "rrule": rrule,
      "message": message,
      "isSimpleEveryXHours": isSimpleEveryXHours,
      if (simple != null) "simple": simple.toJson(),
    };

    final response = await _apiService.put(
      "v2/patients/$patientId/reminders/$reminderId",
      data,
    );

    try {
      return ReminderModel.fromJson(response);
    } catch (e) {
      print("Parsing Error in Update: $e");
      return ReminderModel(
        reminderId: reminderId,
        title: title,
        type: "Updated",
        startDate: startDate is DateTime ? startDate : DateTime.now(),
        endDate: endDate is DateTime ? endDate : DateTime.now(),
        patientID: int.parse(patientId),
        message: message,
      );
    }
  }

  Future<void> deleteReminder({
    required String patientId,
    required String reminderId,
  }) async {
    await _apiService.delete("v2/patients/$patientId/reminders/$reminderId");
  }

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

  Future<void> confirmOccurrence({
    required int reminderId,
    required String occurrenceDateTime,
  }) async {
    await _apiService.post("v2/occurrences/confirm", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 2,
    });
  }

  Future<void> snoozeOccurrence({
    required int reminderId,
    required String occurrenceDateTime,
    int minutes = 15,
  }) async {
    await _apiService.post("v2/occurrences/snooze?minutes=$minutes", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 4,
    });
  }

  Future<void> skipOccurrence({
    required int reminderId,
    required String occurrenceDateTime,
  }) async {
    await _apiService.post("v2/occurrences/skip", {
      "reminderId": reminderId,
      "occurrenceDateTime": occurrenceDateTime,
      "status": 3,
    });
  }
}

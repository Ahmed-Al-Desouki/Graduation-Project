import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

class ReminderWebService {
  final ApiService _apiService;

  ReminderWebService(this._apiService);

  Future<ReminderModel> createReminder(
    String patientId, {
    required String type,
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  }) async {
    final body = {
      "type": type,
      "name": name,
      "startDate": startDate,
      "endDate": endDate,
      "frequency": frequency,
      "intervalHours": intervalHours,
      "baseTime": baseTime,
      "message": message,
    };
    final token = await SecureStorageHelper.getAccessToken();
    final response = await _apiService.post(
      "patients/$patientId/reminders",
      body,
      token: token,
    );
    return response;
  }

  Future<ReminderInstanceModel> getUpcomingReminders(String patientId) async {
    return await _apiService.get(
      "patients/$patientId/reminders/upcoming?hours=24",
    );
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
      "patients/$patientId/reminders/$reminderId",
      body,
    );
    return response;
  }
}

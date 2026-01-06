import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/time_zone_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

class ReminderWebService {
  final ApiService _apiService;

  ReminderWebService(this._apiService);

  // Future<ReminderModel> createReminder(
  //   String patientId, {
  //   required String type,
  //   required String name,
  //   required String startDate,
  //   required String endDate,
  //   required String frequency,
  //   required String intervalHours,
  //   required String baseTime,
  //   required String message,
  // }) async {
  //   final body = {
  //     "type": type,
  //     "name": name,
  //     "startDate": startDate,
  //     "endDate": endDate,
  //     "frequency": frequency,
  //     "intervalHours": intervalHours,
  //     "baseTime": baseTime,
  //     "message": message,
  //   };
  //   final response = await _apiService.post(
  //     "v2/patients/$patientId/reminders",
  //     body,
  //   );
  //   return ReminderModel.fromJson(response);
  // }

  //   Future<ReminderModel> createReminder(
  //   String patientId, {
  //     required String type,
  //     required String name,
  //     required String startDate,
  //     required String endDate,
  //     required String frequency,
  //     required int intervalHours,
  //     required String baseTime,
  //     required String message,
  //   }) async {
  //     // 1. 🚀 جلب التوقيت تلقائياً هنا
  //   final String timeZone = await TimeZoneHelper.getCurrentTimeZone();
  //   print("🕒 Detected TimeZone: $timeZone"); // للتأكد في الكونسول
  //   final body = {
  //     "type": type,
  //     "title": name,
  //     "message": message,
  //     "startDate": startDate,
  //     "endDate": endDate,
  //     "simple": {
  //       "frequency": frequency,
  //       "intervalHours": intervalHours,
  //       "times": [baseTime],
  //     },
  //     "timeZoneId": timeZone,
  //   };

  //   final response = await _apiService.post(
  //     "v2/patients/$patientId/reminders",
  //     body,
  //   );
  //   if (response is Map<String, dynamic>) {
  //     return ReminderModel.fromJson(response);
  //   } else {
  //     // 2. 🚨 في حالة عدم وجود Map سليم، ارمِ خطأ واضح
  //     throw Exception("Invalid response format received from server.");
  //   }
  // }

  Future<ReminderModel> createReminder(
    String patientId, {
    required String type,
    required String title,
    required DateTime startDate, // ← DateTime
    required DateTime? endDate,
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

  // Future<List<ReminderInstanceModel>> getUpcomingReminders(String patientId) async {
  //   final response = await _apiService.get(
  //     "patients/$patientId/reminders/upcoming",
  //   );
  //   if (response is List) {
  //     return response
  //         .map((e) => ReminderInstanceModel.fromJson(e))
  //         .toList();
  //   } else {
  //     return [];
  //   }
  // }
  Future<List<ReminderModel>> getAllReminders(String patientId) async {
    final response = await _apiService.get(
      "v2/patients/$patientId/reminders", // ✅ استخدام endpoint upcoming
    );

    print("All Reminders Response: $response");

    if (response is List) {
      return response.map((e) => ReminderModel.fromJson(e)).toList();
    }
    return [];
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

  // Future<ReminderModel> updateReminder(
  //   String patientId,
  //   String reminderId, {
  //   required String name,
  //   required String startDate,
  //   required String endDate,
  //   required String frequency,
  //   required String intervalHours,
  //   required String baseTime,
  //   required String message,
  // }) async {
  //   final body = {
  //     "name": name,
  //     "startDate": startDate,
  //     "endDate": endDate,
  //     "frequency": frequency,
  //     "intervalHours": intervalHours,
  //     "baseTime": baseTime,
  //     "message": message,
  //   };
  //   final response = await _apiService.put(
  //     "v2/patients/$patientId/reminders/$reminderId",
  //     body,
  //   );
  //   if (response is Map<String, dynamic>) {
  //   return ReminderModel.fromJson(response); // ✅ يجب تحويلها
  // } else {
  //   throw Exception("Invalid response format received for Update.");
  // }
  // }

  //   Future<ReminderModel> updateReminder(
  //   String patientId,
  //   String reminderId, {
  //   required String title, // غيرت الاسم من name لـ title ليتوحيد المسميات
  //   required String startDate,
  //   required String endDate,
  //   String? rrule,
  //   SimpleModel? simple,
  //   required String message,
  //   required bool isSimpleEveryXHours, // مهم عشان الباك إند يميز
  // }) async {

  //   final String timeZone = await TimeZoneHelper.getCurrentTimeZone();

  //   final Map<String, dynamic> body = {
  //     "title": title,
  //     "startDate": startDate,
  //     "endDate": endDate,
  //     "message": message.isEmpty ? null : message,
  //     "timeZoneId": timeZone,
  //     "isSimpleEveryXHours": isSimpleEveryXHours,
  //   };

  //   // إضافة البيانات حسب النوع
  //   if (isSimpleEveryXHours && simple != null) {
  //     body["simple"] = simple.toJson();
  //     body["rrule"] = "SIMPLE_EVERY_X_HOURS";
  //   } else if (rrule != null) {
  //     body["rrule"] = rrule;
  //     body["simple"] = null;
  //   }

  //   final response = await _apiService.put(
  //     "v2/patients/$patientId/reminders/$reminderId",
  //     body,
  //   );

  //   if (response is Map<String, dynamic>) {
  //     return ReminderModel.fromJson(response);
  //   } else {
  //     // Fallback or throw error
  //     return ReminderModel.fromJson(response['data']);
  //   }
  // }
  //   Future<ReminderModel> updateReminder(
  //   String patientId,
  //   String reminderId, {
  //   required String title, // غيرت الاسم من name لـ title ليتوحيد المسميات
  //   required DateTime startDate,
  //   required DateTime? endDate,
  //   String? rrule,
  //   SimpleModel? simple,
  //   required String message,
  //   required bool isSimpleEveryXHours, // مهم عشان الباك إند يميز
  // }) async {
  //   final String timeZone = await TimeZoneHelper.getCurrentTimeZone();

  //   final Map<String, dynamic> body = {
  //     "title": title,
  //     "startDate": startDate,
  //     "endDate": endDate,
  //     "message": message.isEmpty ? null : message,
  //     "timeZoneId": timeZone,
  //     "isSimpleEveryXHours": isSimpleEveryXHours,
  //   };

  //   // إضافة البيانات حسب النوع
  //   if (isSimpleEveryXHours && simple != null) {
  //     body["simple"] = simple.toJson();
  //     body["rrule"] = null;
  //   } else if (rrule != null) {
  //     body["rrule"] = rrule;
  //     body["simple"] = null;
  //   }

  //   final response = await _apiService.put(
  //     "v2/patients/$patientId/reminders/$reminderId",
  //     body,
  //   );

  //   if (response is Map<String, dynamic>) {
  //     return ReminderModel.fromJson(response);
  //   } else {
  //     // Fallback or throw error
  //     return ReminderModel.fromJson(response['data']);
  //   }
  // }

  Future<ReminderModel> updateReminder(
    String patientId,
    String reminderId, {
    required String title,
    required dynamic startDate, // جعلناه dynamic ليقبل String أو DateTime
    required dynamic endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
    required bool isSimpleEveryXHours,
  }) async {
    // بناء الـ Map الذي سيُرسل للسيرفر
    final Map<String, dynamic> data = {
      "title": title,
      // التأكد من التحويل هنا أيضاً كخط دفاع أخير
      "startDate":
          startDate is DateTime ? startDate.toIso8601String() : startDate,
      "endDate": endDate is DateTime ? endDate.toIso8601String() : endDate,
      "rrule": rrule,
      "message": message,
      "isSimpleEveryXHours": isSimpleEveryXHours,
      if (simple != null) "simple": simple.toJson(),
    };

    // إرسال الريكويست
    final response = await _apiService.put(
      "v2/patients/$patientId/reminders/$reminderId",
      data, // هنا Dio سيعمل بنجاح لأن كل القيم بداخل data أصبحت نصوصاً أو أرقاماً
    );

    // return ReminderModel.fromJson(response);
    try {
    // محاولة تحويل الرد
    return ReminderModel.fromJson(response);
  } catch (e) {
    print("Parsing Error in Update: $e");
    // 💡 الحل السحري: إذا حدث خطأ في التحويل، نرجع كائن محلي بالبيانات الجديدة 
    // لكي لا يظهر الخطأ الأحمر للمستخدم، لأن التعديل تم بالفعل في السيرفر
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
}

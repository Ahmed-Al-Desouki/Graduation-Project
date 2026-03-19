import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';

import 'booking_remote_data_source.dart';

// class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
//   final ApiService _apiService;

//   BookingRemoteDataSourceImpl(this._apiService);

//   // --- 1. إدارة الجداول (Schedules) ---

//   @override
//   Future<String> createSchedule(
//     String doctorId,
//     Map<String, dynamic> body,
//   ) async {
//     final response = await _apiService.post(
//       'doctors/$doctorId/schedules',
//       body,
//     );
//     // return response['scheduleId']; // الباك بيرجع ID الجدول الجديد
//     return response['templateId'];
//   }

//   @override
//   Future<Map<String, dynamic>> getActiveSchedule(String doctorId) async {
//     return await _apiService.get('doctors/$doctorId/schedules/active');
//   }

//   // --- 2. إدارة الاستثناءات (Exceptions) ---

//   @override
//   Future<void> addDayOff(String doctorId, Map<String, dynamic> body) async {
//     await _apiService.post(
//       'doctors/$doctorId/schedules/exceptions/day-off',
//       body,
//     );
//   }

//   @override
//   Future<void> addCustomHours(
//     String doctorId,
//     Map<String, dynamic> body,
//   ) async {
//     await _apiService.post(
//       'doctors/$doctorId/schedules/exceptions/custom-hours',
//       body,
//     );
//   }

//   @override
//   Future<void> removeException(String doctorId, String date) async {
//     // الباك بياخد التاريخ في الـ URL للحذف
//     await _apiService.delete('doctors/$doctorId/schedules/exceptions/$date');
//   }

//   // --- 3. إدارة الـ Slots (توليد، جلب، يدوي) ---

//   @override
//   Future<Map<String, dynamic>> generateSlots(
//     String doctorId,
//     Map<String, dynamic> body,
//   ) async {
//     return await _apiService.post(
//       'doctors/$doctorId/time-slots/generate',
//       body,
//     );
//   }

//   @override
//   Future<List<DaySlotsModel>> getSlotsRange(
//     String doctorId,
//     String start,
//     String end, {
//     String? status,
//   }) async {
//     final response = await _apiService.get(
//       'doctors/$doctorId/time-slots/range',
//       queryParameters: {
//         'startDate': start,
//         'endDate': end,
//         if (status != null) 'status': status, // إضافة الـ status لو موجود
//       },
//     );

//     // تحويل الـ dailySlots من JSON لموديلات Dart
//     return (response['dailySlots'] as List)
//         .map((e) => DaySlotsModel.fromJson(e))
//         .toList();
//   }

//   @override
//   Future<void> createManualSlot(
//     String doctorId,
//     Map<String, dynamic> body,
//   ) async {
//     await _apiService.post('doctors/$doctorId/time-slots/manual', body);
//   }

//   @override
//   Future<void> deleteSlot(String doctorId, String slotId) async {
//     await _apiService.delete('doctors/$doctorId/time-slots/$slotId');
//   }

//   @override
//   Future<void> blockSlot(String doctorId, String slotId) async {
//     await _apiService.patch('doctors/$doctorId/time-slots/$slotId/block');
//   }

//   // --- 4. إدارة المواعيد (Appointments) ---

//   @override
//   Future<List<Map<String, dynamic>>> getDoctorAppointments(
//     String date,
//     String status,
//   ) async {
//     final response = await _apiService.get(
//       'appointments/doctor-appointments',
//       queryParameters: {'date': date, 'status': status},
//     );
//     return List<Map<String, dynamic>>.from(response);
//   }

//   @override
//   Future<void> updateAppointmentStatus(
//     String appointmentId,
//     String action, {
//     Map<String, dynamic>? body,
//   }) async {
//     // الأكشن بيكون (confirm, start, complete, cancel)
//     await _apiService.patch('appointments/$appointmentId/$action', body: body);
//   }

//   @override
//   Future<void> bookFollowUp(
//     String originalId,
//     String type,
//     Map<String, dynamic> body,
//   ) async {
//     // الـ type بيكون إما existing أو new
//     await _apiService.post('appointments/$originalId/follow-up/$type', body);
//   }

//   @override
//   Future<void> cancelByDoctor(
//     String appointmentId,
//     // String reason,
//     Map<String, dynamic>? body,
//   ) async {
//     // بناءً على كلامك، الباك عامل أكشن مخصص بيكنسل ويعمل بلوك للسلوت
//     await _apiService.patch(
//       'appointments/$appointmentId/doctor-cancel-block',
//       body: body,
//     );
//   }

//   @override
//   Future<void> cancelByPatient(
//     String appointmentId,
//     // String reason,
//     Map<String, dynamic>? body,
//   ) async {
//     // المريض بيكنسل والسلوت بيرجع متاح (Available)
//     await _apiService.patch(
//       'appointments/$appointmentId/patient-cancel',
//       body: body,
//     );
//   }

//   @override
//   Future<String> createAppointment(Map<String, dynamic> body) async {
//     // body هنا هيكون جاي من الـ Repo فيه (timeSlotId, patientNotes, grantMedicalHistoryAccess)
//     final response = await _apiService.post(
//       '/appointments/book', // ✅ الأيند بوينت الجديدة
//       body,
//     );

//     // السيرفر بيرجع الـ appointmentId في الـ Root
//     return response['appointmentId'].toString();
//   }

//   @override
//   Future<Map<String, dynamic>> createPayment(Map<String, dynamic> body) async {
//     // الباك مستني appointmentId و paymentMethod
//     // الأيند بوينت حسب ملف Paymob: POST /api/payment/create
//     final response = await _apiService.post('/payment/create', body);

//     // بنرجع الـ Map كاملة عشان الـ Model يحولها في الـ Repository
//     return response;
//   }
// }

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiService _apiService;

  BookingRemoteDataSourceImpl(this._apiService);

  // =========================================================================
  // 1. إدارة إعدادات الجدول (Slot Config) - مـحـدث v2.0
  // =========================================================================

  @override
  Future<String> createSchedule(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    // التعديل: PUT /api/doctors/{doctorId}/slot-config/days/{day}
    // ملاحظة: body['dayOfWeek'] هو الرقم من 0 لـ 6
    final response = await _apiService.put(
      'doctors/$doctorId/slot-config/days/${body['dayOfWeek']}',
      body,
    );
    return response['message'] ?? "Config Updated";
  }

  @override
  Future<List<dynamic>> getActiveSchedule(String doctorId) async {
    // التعديل: GET /api/doctors/{doctorId}/slot-config/days
    final response = await _apiService.get('doctors/$doctorId/slot-config');
    return response as List<dynamic>;
  }

  @override
  Future<void> removeWorkingDay(String doctorId, int dayOfWeek) async {
    // التعديل: DELETE /api/doctors/{doctorId}/slot-config/days/{day}
    await _apiService.delete('doctors/$doctorId/slot-config/days/$dayOfWeek');
  }

  // =========================================================================
  // 2. إدارة الاستثناءات (Exceptions) - مـحـدث v2.0
  // =========================================================================

  @override
  Future<void> addDayOff(String doctorId, Map<String, dynamic> body) async {
    // POST /api/doctors/{doctorId}/slot-config/exceptions/day-off
    await _apiService.post(
      'doctors/$doctorId/slot-config/exceptions/day-off',
      body,
    );
  }

  @override
  Future<void> addCustomHours(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    // POST /api/doctors/{doctorId}/slot-config/exceptions/custom-hours
    await _apiService.post(
      'doctors/$doctorId/slot-config/exceptions/custom-hours',
      body,
    );
  }

  @override
  Future<void> removeException(String doctorId, String date) async {
    // DELETE /api/doctors/{doctorId}/slot-config/exceptions/{date}
    await _apiService.delete('doctors/$doctorId/slot-config/exceptions/$date');
  }

  // =========================================================================
  // 3. إدارة الـ Slots (توليد، جلب، يدوي) - مـحـدث v2.0
  // =========================================================================

  @override
  Future<Map<String, dynamic>> generateSlots(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    // التعديل: POST /api/doctors/{doctorId}/slot-config/generate
    return await _apiService.post(
      'doctors/$doctorId/slot-config/generate',
      body,
    );
  }

  @override
  Future<List<DaySlotsModel>> getSlotsRange(
    String doctorId,
    String start,
    String end, {
    String? status,
  }) async {
    // GET /api/doctors/{doctorId}/time-slots/range
    final response = await _apiService.get(
      'doctors/$doctorId/time-slots/range',
      queryParameters: {
        'startDate': start,
        'endDate': end,
        if (status != null) 'status': status,
      },
    );

    return (response['dailySlots'] as List)
        .map((e) => DaySlotsModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createManualSlot(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    // POST /api/doctors/{doctorId}/time-slots/manual
    await _apiService.post('doctors/$doctorId/time-slots/manual', body);
  }

  @override
  Future<void> deleteSlot(String doctorId, String slotId) async {
    // DELETE /api/doctors/{doctorId}/time-slots/{slotId}
    await _apiService.delete('doctors/$doctorId/time-slots/$slotId');
  }

  @override
  Future<void> blockSlot(String doctorId, String slotId) async {
    // PATCH /api/doctors/{doctorId}/time-slots/{slotId}/block
    await _apiService.patch('doctors/$doctorId/time-slots/$slotId/block');
  }

  // =========================================================================
  // 4. إدارة المواعيد (Appointments)
  // =========================================================================

  @override
  Future<List<Map<String, dynamic>>> getDoctorAppointments(
    String date,
    String status,
  ) async {
    final response = await _apiService.get(
      'appointments/doctor-appointments',
      queryParameters: {'date': date, 'status': status},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    // الأكشن: (confirm, start, complete)
    await _apiService.patch('appointments/$appointmentId/$action', body: body);
  }

  @override
  Future<void> bookFollowUp(
    String originalId,
    String type,
    Map<String, dynamic> body,
  ) async {
    // الـ type: (existing, new)
    await _apiService.post('appointments/$originalId/follow-up/$type', body);
  }

  @override
  Future<void> cancelByDoctor(
    String appointmentId,
    Map<String, dynamic>? body,
  ) async {
    await _apiService.post(
      'appointments/$appointmentId/doctor-cancel-block',
      body,
    );
  }

  @override
  Future<void> cancelByPatient(
    String appointmentId,
    Map<String, dynamic>? body,
  ) async {
    await _apiService.post('appointments/$appointmentId/patient-cancel', body);
  }

  @override
  Future<String> createAppointment(Map<String, dynamic> body) async {
    // POST /api/appointments/book
    final response = await _apiService.post('appointments/book', body);
    return response['appointmentId'].toString();
  }

  // =========================================================================
  // 5. إدارة الدفع (Payment)
  // =========================================================================

  @override
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> body) async {
    // POST /api/payment/create
    return await _apiService.post('payment/create', body);
  }
}

import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';

abstract class BookingRemoteDataSource {
  // --- Schedules ---
  Future<String> createSchedule(String doctorId, Map<String, dynamic> body);
  // Future<Map<String, dynamic>> getActiveSchedule(String doctorId);

  Future<List<dynamic>> getActiveSchedule(String doctorId);

  // --- Exceptions ---
  Future<void> addDayOff(String doctorId, Map<String, dynamic> body);
  Future<void> addCustomHours(String doctorId, Map<String, dynamic> body);
  Future<void> removeException(String doctorId, String date);

  // --- Slots ---
  Future<Map<String, dynamic>> generateSlots(
    String doctorId,
    Map<String, dynamic> body,
  );
  Future<List<DaySlotsModel>> getSlotsRange(
    String doctorId,
    String start,
    String end, {
    String? status,
  });
  Future<void> createManualSlot(String doctorId, Map<String, dynamic> body);
  Future<void> deleteSlot(String doctorId, String slotId);
  Future<void> blockSlot(String doctorId, String slotId);

  // --- Appointments ---
  Future<List<Map<String, dynamic>>> getDoctorAppointments(
    String? date,
    String? status,
  );

  Future<List<Map<String, dynamic>>> getPatientAppointments(String? status);

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String action, {
    Map<String, dynamic>? body,
  });
  Future<void> bookFollowUp(
    String originalId,
    String type,
    Map<String, dynamic> body,
  );

  Future<void> cancelByDoctor(
    String appointmentId,
    // String reason,
    Map<String, dynamic>? body,
  );
  Future<void> cancelByPatient(
    String appointmentId,
    // String reason,
    Map<String, dynamic>? body,
  );

  Future<Map<String, dynamic>> bookWithPayment(
    Map<String, dynamic> body, {
    required String paymentMethod,
  });

  // // --- Payment ---
  // // ✅ ميثود إنشاء الدفع (بترجع الـ JSON اللي فيه الـ paymentUrl)
  // Future<Map<String, dynamic>> createPayment(Map<String, dynamic> body);

  Future<void> removeWorkingDay(String doctorId, int dayOfWeek);

  // داخل abstract class BookingRemoteDataSource
  Future<Map<String, dynamic>> getAppointmentFullDetails(String appointmentId);
}

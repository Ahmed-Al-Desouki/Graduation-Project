import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';
import 'package:graduation_project/features/chat/data/models/chat_model.dart';

abstract class BookingRemoteDataSource {
  Future<String> createSchedule(String doctorId, Map<String, dynamic> body);

  Future<List<dynamic>> getActiveSchedule(String doctorId);

  Future<void> addDayOff(String doctorId, Map<String, dynamic> body);
  Future<void> addCustomHours(String doctorId, Map<String, dynamic> body);
  Future<void> removeException(String doctorId, String date);

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

  Future<void> cancelByDoctor(String appointmentId, Map<String, dynamic>? body);
  Future<void> cancelByPatient(
    String appointmentId,
    Map<String, dynamic>? body,
  );

  Future<Map<String, dynamic>> bookWithPayment(
    Map<String, dynamic> body, {
    required String paymentMethod,
  });

  Future<void> removeWorkingDay(String doctorId, int dayOfWeek);

  Future<Map<String, dynamic>> getAppointmentFullDetails(String appointmentId);

  Future<void> createChatRoom(ChatModel chatModel);
}

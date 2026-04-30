import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';

abstract class IBookingRepository {
  // --- Schedules & Generation ---
  Future<Either<Failure, String>> createSchedule(ScheduleEntity schedule);
  Future<Either<Failure, void>> generateSlots(
    String doctorId,
    DateTime start,
    DateTime end,
    bool regenerate,
  );

  // --- Exceptions ---
  Future<Either<Failure, void>> addDayOff(
    String doctorId,
    DateTime date,
    String reason,
  );
  Future<Either<Failure, void>> addCustomHours(
    String doctorId,
    DateTime date,
    String start,
    String end,
    String reason,
  );
  Future<Either<Failure, void>> removeException(String doctorId, DateTime date);

  // --- Slots Management ---
  Future<Either<Failure, List<DaySlotsEntity>>> getSlotsRange(
    String doctorId,
    DateTime start,
    DateTime end, {
    String? status,
  });
  Future<Either<Failure, void>> createManualSlot(
    String doctorId,
    DateTime date,
    String start,
    String end,
  );
  Future<Either<Failure, void>> deleteSlot(String doctorId, String slotId);
  Future<Either<Failure, void>> blockSlot(String doctorId, String slotId);

  // --- Appointments Control ---
  Future<Either<Failure, List<AppointmentFullDetailsEntity>>>
  getDoctorAppointments(DateTime? date, String? status);
  Future<Either<Failure, void>> confirmAppointment(String id);
  Future<Either<Failure, void>> startAppointment(String id);
  Future<Either<Failure, void>> completeAppointment(String id);
  // Future<Either<Failure, void>> cancelAppointment(String id, String reason);
  Future<Either<Failure, void>> cancelAppointmentByDoctor(
    String id,
    String reason,
  );
  Future<Either<Failure, void>> cancelAppointmentByPatient(
    String id,
    String reason,
  );

  // --- Follow-up ---
  Future<Either<Failure, void>> bookFollowUpExisting(
    String originalId,
    String slotId,
    String notes,
    String instructions,
  );
  Future<Either<Failure, void>> bookFollowUpNew(
    String originalId,
    DateTime date,
    String start,
    int duration,
    String notes,
    String instructions,
  );

  Future<Either<Failure, ScheduleEntity>> getActiveSchedule(String doctorId);

  // Future<Either<Failure, String>> createAppointment(BookingEntity booking);
  Future<Either<Failure, Map<String, dynamic>>> bookAndPay(
    BookingEntity booking,
  );

  Future<Either<Failure, void>> removeWorkingDay(
    String doctorId,
    int dayOfWeek,
  );

  Future<Either<Failure, AppointmentFullDetailsEntity>>
  getAppointmentFullDetails(String appointmentId);

  Future<Either<Failure, List<AppointmentFullDetailsEntity>>>
  getPatientAppointments({String? status});
}

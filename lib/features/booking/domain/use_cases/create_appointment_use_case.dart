import 'package:dartz/dartz.dart'; // ✅ تأكد من وجود الـ import ده
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class CreateAppointmentUseCase {
  final IBookingRepository repository; // يفضل إضافة final
  CreateAppointmentUseCase(this.repository);

  // ✅ تغيير الـ Return Type ليكون Either
  Future<Either<Failure, String>> call({
    required String slotId,
    required String reason,
    bool grantAccess = false,
  }) async {
    return await repository.createAppointment(
      BookingEntity(
        timeSlotId: slotId,
        patientNotes: reason,
        grantMedicalHistoryAccess: grantAccess,
      ),
    );
  }
}

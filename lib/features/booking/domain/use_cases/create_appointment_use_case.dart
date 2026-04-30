import 'package:dartz/dartz.dart'; // ✅ تأكد من وجود الـ import ده
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class CreateAppointmentUseCase {
  final IBookingRepository repository;
  CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String slotId,
    required String reason,
    required String paymentMethod,
    bool grantAccess = false,
  }) async {
    return await repository.bookAndPay(
      BookingEntity(
        timeSlotId: slotId,
        patientNotes: reason,
        grantMedicalHistoryAccess: grantAccess,
        paymentMethod: paymentMethod,
      ),
    );
  }
}

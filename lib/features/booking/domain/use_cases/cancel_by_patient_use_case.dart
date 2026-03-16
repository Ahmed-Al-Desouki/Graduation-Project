import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class CancelByPatientUseCase {
  final IBookingRepository repository;
  CancelByPatientUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String reason) {
    return repository.cancelAppointmentByPatient(id, reason);
  }
}

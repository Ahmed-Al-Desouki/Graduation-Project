import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class CancelBlockByDoctorUseCase {
  final IBookingRepository repository;
  CancelBlockByDoctorUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String reason) {
    return repository.cancelAppointmentByDoctor(id, reason);
  }
}

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class RemoveExceptionUseCase {
  final IBookingRepository repository;
  RemoveExceptionUseCase(this.repository);

  Future<Either<Failure, void>> call(String doctorId, DateTime date) {
    return repository.removeException(doctorId, date);
  }
}

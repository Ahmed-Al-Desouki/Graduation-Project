import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class AddDayOffUseCase {
  final IBookingRepository repository;
  AddDayOffUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String doctorId,
    DateTime date,
    String reason,
  ) {
    return repository.addDayOff(doctorId, date, reason);
  }
}

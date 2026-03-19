import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class RemoveWorkingDayUseCase {
  final IBookingRepository repository;
  RemoveWorkingDayUseCase(this.repository);
  Future<Either<Failure, void>> call(String doctorId, int dayOfWeek) =>
      repository.removeWorkingDay(doctorId, dayOfWeek);
}

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class AddCustomHoursUseCase {
  final IBookingRepository repository;
  AddCustomHoursUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String doctorId,
    DateTime date,
    String start,
    String end,
    String reason,
  ) {
    return repository.addCustomHours(doctorId, date, start, end, reason);
  }
}

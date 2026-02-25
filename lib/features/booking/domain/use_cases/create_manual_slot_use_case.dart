import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class CreateManualSlotUseCase {
  final IBookingRepository repository;
  CreateManualSlotUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String doctorId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    return await repository.createManualSlot(
      doctorId,
      date,
      startTime,
      endTime,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class GenerateSlotsUseCase {
  final IBookingRepository repository;
  GenerateSlotsUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String doctorId,
    required DateTime start,
    required DateTime end,
    required bool regenerate,
  }) async {
    return await repository.generateSlots(doctorId, start, end, regenerate);
  }
}

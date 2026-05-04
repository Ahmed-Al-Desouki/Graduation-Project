import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class RestoreBlockedSlotsUseCase {
  final IBookingRepository repository;

  RestoreBlockedSlotsUseCase(this.repository);

  Future<Either<Failure, void>> call(String doctorId, List<String> slotIds) {
    return repository.restoreBlockedSlots(doctorId, slotIds);
  }
}

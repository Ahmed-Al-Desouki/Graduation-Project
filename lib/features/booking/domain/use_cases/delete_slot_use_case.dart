import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_booking_repository.dart';

class DeleteSlotUseCase {
  final IBookingRepository repository;
  DeleteSlotUseCase(this.repository);

  Future<Either<Failure, void>> call(String doctorId, String slotId) async {
    return await repository.deleteSlot(doctorId, slotId);
  }
}

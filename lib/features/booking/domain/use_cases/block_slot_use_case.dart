import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_booking_repository.dart';

class BlockSlotUseCase {
  final IBookingRepository repository;
  BlockSlotUseCase(this.repository);

  Future<Either<Failure, void>> call(String doctorId, String slotId) async {
    return await repository.blockSlot(doctorId, slotId);
  }
}

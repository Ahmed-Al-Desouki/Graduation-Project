import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class BookFollowUpUseCase {
  final IBookingRepository repository;
  BookFollowUpUseCase(this.repository);

  // للمتابعة في Slot موجودة فعلياً
  Future<Either<Failure, void>> existingSlot({
    required String originalId,
    required String slotId,
    required String notes,
    required String instructions,
  }) async {
    return await repository.bookFollowUpExisting(
      originalId,
      slotId,
      notes,
      instructions,
    );
  }

  // للمتابعة في موعد جديد يحدده الدكتور يدوياً
  Future<Either<Failure, void>> newSlot({
    required String originalId,
    required DateTime date,
    required String startTime,
    required int duration,
    required String notes,
    required String instructions,
  }) async {
    return await repository.bookFollowUpNew(
      originalId,
      date,
      startTime,
      duration,
      notes,
      instructions,
    );
  }
}

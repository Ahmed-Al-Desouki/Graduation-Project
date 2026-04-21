import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/day_slots_entity.dart';
import '../repositories/i_booking_repository.dart';

class GetSlotsRangeUseCase {
  final IBookingRepository repository;

  GetSlotsRangeUseCase(this.repository);

  // البارامترات المطلوبة لجلب بيانات الكالندر
  Future<Either<Failure, List<DaySlotsEntity>>> call({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    return await repository.getSlotsRange(
      doctorId,
      startDate,
      endDate,
      status: status,
    );
  }
}

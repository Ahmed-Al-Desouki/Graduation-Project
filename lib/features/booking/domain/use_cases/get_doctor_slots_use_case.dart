import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class GetDoctorSlotsUseCase {
  final IBookingRepository repository;
  GetDoctorSlotsUseCase(this.repository);

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

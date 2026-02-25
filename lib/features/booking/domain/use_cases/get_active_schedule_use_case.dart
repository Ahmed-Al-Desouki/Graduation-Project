import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

class GetActiveScheduleUseCase {
  final IBookingRepository repository;
  GetActiveScheduleUseCase(this.repository);

  Future<Either<Failure, ScheduleEntity>> call(String doctorId) async {
    return await repository.getActiveSchedule(doctorId);
  }
}

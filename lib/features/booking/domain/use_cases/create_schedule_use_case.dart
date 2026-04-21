import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entity.dart';
import '../repositories/i_booking_repository.dart';

class CreateScheduleUseCase {
  final IBookingRepository repository;
  CreateScheduleUseCase(this.repository);

  Future<Either<Failure, String>> call(ScheduleEntity schedule) async {
    return await repository.createSchedule(schedule);
  }
}

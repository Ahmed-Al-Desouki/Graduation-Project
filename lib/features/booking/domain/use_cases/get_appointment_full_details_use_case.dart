import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment_full_details_entity.dart';

class GetAppointmentFullDetailsUseCase {
  final IBookingRepository repository;

  GetAppointmentFullDetailsUseCase(this.repository);

  Future<Either<Failure, AppointmentFullDetailsEntity>> call(
    String appointmentId,
  ) async {
    return await repository.getAppointmentFullDetails(appointmentId);
  }
}

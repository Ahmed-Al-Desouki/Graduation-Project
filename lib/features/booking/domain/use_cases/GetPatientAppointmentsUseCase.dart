import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment_full_details_entity.dart';
import '../repositories/i_booking_repository.dart';

class GetPatientAppointmentsUseCase {
  final IBookingRepository repository;

  GetPatientAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentFullDetailsEntity>>> call({
    String? status,
  }) async {
    return await repository.getPatientAppointments(status: status);
  }
}

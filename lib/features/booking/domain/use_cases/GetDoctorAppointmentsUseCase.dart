import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment_full_details_entity.dart';
import '../repositories/i_booking_repository.dart';

class GetDoctorAppointmentsUseCase {
  final IBookingRepository repository;

  GetDoctorAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentFullDetailsEntity>>> call({
    DateTime? date,
    String? status,
  }) async {
    return await repository.getDoctorAppointments(date, status);
  }
}

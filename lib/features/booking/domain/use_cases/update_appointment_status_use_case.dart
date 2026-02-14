import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/i_booking_repository.dart';

enum AppointmentAction { confirm, start, complete, cancel }

class UpdateAppointmentStatusUseCase {
  final IBookingRepository repository;
  UpdateAppointmentStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String id,
    AppointmentAction action, {
    String? cancelReason,
  }) async {
    switch (action) {
      case AppointmentAction.confirm:
        return await repository.confirmAppointment(id);
      case AppointmentAction.start:
        return await repository.startAppointment(id);
      case AppointmentAction.complete:
        return await repository.completeAppointment(id);
      case AppointmentAction.cancel:
        return await repository.cancelAppointment(
          id,
          cancelReason ?? "No reason provided",
        );
    }
  }
}

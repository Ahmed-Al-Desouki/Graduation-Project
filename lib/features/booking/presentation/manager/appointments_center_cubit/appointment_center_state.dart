part of 'appointment_center_cubit.dart';

@immutable
sealed class AppointmentsCenterState {}

final class AppointmentCenterInitial extends AppointmentsCenterState {}

class AppointmentsCenterLoading extends AppointmentsCenterState {}

class AppointmentsCenterSuccess extends AppointmentsCenterState {
  final List<AppointmentFullDetailsEntity> appointments;
  final List<AppointmentFullDetailsEntity>
  fullAppointments; // 🚨 لازم تكون موجودة
  final String? currentStatus;

  AppointmentsCenterSuccess({
    required this.appointments,
    required this.fullAppointments,
    this.currentStatus,
  });
}

class AppointmentsCenterFailure extends AppointmentsCenterState {
  final String errMessage;
  AppointmentsCenterFailure(this.errMessage);
}

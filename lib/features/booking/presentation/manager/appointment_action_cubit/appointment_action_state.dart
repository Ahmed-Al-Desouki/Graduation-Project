part of 'appointment_action_cubit.dart';

@immutable
sealed class AppointmentActionState {}

final class AppointmentActionInitial extends AppointmentActionState {}

final class AppointmentActionLoading extends AppointmentActionState {}

// حالة النجاح العامة (بنبعت معاه رسالة عشان نظهرها في SnackBar)
final class AppointmentActionSuccess extends AppointmentActionState {
  final String message;
  final String? actionType; // لتمييز أي عملية نجحت (confirm, start, etc.)
  AppointmentActionSuccess(this.message, {this.actionType});
}

final class AppointmentActionFailure extends AppointmentActionState {
  final String errMessage;
  AppointmentActionFailure(this.errMessage);
}

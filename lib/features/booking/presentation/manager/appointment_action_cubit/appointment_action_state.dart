part of 'appointment_action_cubit.dart';

@immutable
sealed class AppointmentActionState {}

final class AppointmentActionInitial extends AppointmentActionState {}

final class AppointmentActionLoading extends AppointmentActionState {}

final class AppointmentActionSuccess extends AppointmentActionState {
  final String message;
  final String? actionType;
  AppointmentActionSuccess(this.message, {this.actionType});
}

final class AppointmentActionFailure extends AppointmentActionState {
  final String errMessage;
  AppointmentActionFailure(this.errMessage);
}

class PaymentNavigatedToWebView extends AppointmentActionState {
  final String url;
  final Map<String, dynamic> bookingData;

  PaymentNavigatedToWebView(this.url, {required this.bookingData});
}

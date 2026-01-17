import 'package:meta/meta.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

@immutable
sealed class ReminderState {}

final class ReminderInitial extends ReminderState {}

final class ReminderLoading extends ReminderState {}

final class ReminderCreateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderCreateSuccess({required this.reminder});
}

final class ReminderCreateFailure extends ReminderState {
  final String errMessage;
  ReminderCreateFailure({required this.errMessage});
}

final class ReminderUpdateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderUpdateSuccess({required this.reminder});
}

final class ReminderUpdateFailure extends ReminderState {
  final String errMessage;
  ReminderUpdateFailure({required this.errMessage});
}

final class UpcomingRemindersSuccess extends ReminderState {
  final List<ReminderInstanceModel> medications;
  final List<ReminderInstanceModel> appointments;
  final List<ReminderInstanceModel> customs;

  UpcomingRemindersSuccess({
    required this.medications,
    required this.appointments,
    this.customs = const [],
  });
}

final class UpcomingRemindersFailure extends ReminderState {
  final String errMessage;
  UpcomingRemindersFailure({required this.errMessage});
}

final class GetAllRemindersLoading extends ReminderState {}

final class GetAllRemindersSuccess extends ReminderState {
  final List<ReminderModel> reminders;
  GetAllRemindersSuccess({required this.reminders});
}

final class GetAllRemindersFailure extends ReminderState {
  final String errMessage;
  GetAllRemindersFailure({required this.errMessage});
}

final class ReminderDeleteLoading extends ReminderState {}

final class ReminderDeleteSuccess extends ReminderState {
  final String message;
  ReminderDeleteSuccess({required this.message});
}

final class ReminderDeleteFailure extends ReminderState {
  final String errMessage;
  ReminderDeleteFailure({required this.errMessage});
}

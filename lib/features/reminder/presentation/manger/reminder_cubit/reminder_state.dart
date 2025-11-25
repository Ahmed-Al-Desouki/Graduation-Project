// import 'package:equatable/equatable.dart';
// import 'package:graduation_project/features/auth/data/models/reminder_instance_model.dart';
// import 'package:graduation_project/features/auth/data/models/reminder_model.dart';

// abstract class ReminderState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class ReminderInitial extends ReminderState {}

// class ReminderLoading extends ReminderState {}

// class ReminderCreated extends ReminderState {
//   final ReminderModel reminder;
//   ReminderCreated(this.reminder);
// }

// class ReminderUpdated extends ReminderState {
//   final ReminderModel reminder;
//   ReminderUpdated(this.reminder);
// }

// class UpcomingRemindersLoaded extends ReminderState {
//   final ReminderInstanceModel instance;
//   UpcomingRemindersLoaded(this.instance);
// }

// class ReminderError extends ReminderState {
//   final String message;
//   ReminderError(this.message);
// }
// -----------------------------------------------------
// part of 'reminder_cubit.dart';

// @immutable
// sealed class ReminderState {}

// class ReminderInitial extends ReminderState {}

// class ReminderLoading extends ReminderState {}

// class ReminderFailure extends ReminderState {
//   final String message;
//   ReminderFailure(this.message);
// }

// class ReminderLoaded extends ReminderState {
//   final List<dynamic> reminders;
//   ReminderLoaded(this.reminders);
// }
// lib/features/auth/presentation/manger/reminder_cubit/reminder_state.dart
// -------------------------------------------------

// part of 'reminder_cubit.dart';

// abstract class ReminderState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class ReminderInitial extends ReminderState {}

// class ReminderLoading extends ReminderState {}

// class ReminderCreated extends ReminderState {
//   final ReminderModel reminder;
//   ReminderCreated(this.reminder);

//   @override
//   List<Object?> get props => [reminder];
// }

// class ReminderUpdated extends ReminderState {
//   final ReminderModel reminder;
//   ReminderUpdated(this.reminder);

//   @override
//   List<Object?> get props => [reminder];
// }

// class UpcomingRemindersLoaded extends ReminderState {
//   final ReminderInstanceModel instance;
//   UpcomingRemindersLoaded(this.instance);

//   @override
//   List<Object?> get props => [instance];
// }

// class ReminderError extends ReminderState {
//   final String message;
//   ReminderError(this.message);

//   @override
//   List<Object?> get props => [message];
// }
// --------------------------------------------
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

@immutable
sealed class ReminderState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ReminderInitial extends ReminderState {}

final class ReminderLoading extends ReminderState {}

final class ReminderCreateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderCreateSuccess(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

final class ReminderCreateFailure extends ReminderState {
  final String message;
  ReminderCreateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ReminderUpdateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderUpdateSuccess(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

final class ReminderUpdateFailure extends ReminderState {
  final String message;
  ReminderUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class UpcomingRemindersSuccess extends ReminderState {
  final ReminderInstanceModel instance;
  UpcomingRemindersSuccess(this.instance);

  @override
  List<Object?> get props => [instance];
}

final class UpcomingRemindersFailure extends ReminderState {
  final String message;
  UpcomingRemindersFailure(this.message);

  @override
  List<Object?> get props => [message];
}

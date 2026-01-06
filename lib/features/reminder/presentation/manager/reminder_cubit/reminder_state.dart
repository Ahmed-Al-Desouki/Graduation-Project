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
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

@immutable
sealed class ReminderState {}

final class ReminderInitial extends ReminderState {}

final class ReminderLoading extends ReminderState {}

// --- حالات إنشاء وتحديث ---
final class ReminderCreateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderCreateSuccess({required this.reminder}); // 💡 استخدمنا Named Parameter
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

// --- حالات جلب التذكيرات (Upcoming) ---
final class UpcomingRemindersSuccess extends ReminderState {
  final List<ReminderInstanceModel> medications;
  final List<ReminderInstanceModel> appointments;
  final List<ReminderInstanceModel> customs;

  UpcomingRemindersSuccess({
    required this.medications,
    required this.appointments,
    this.customs= const [],
  });
}

final class UpcomingRemindersFailure extends ReminderState {
  final String errMessage;
  UpcomingRemindersFailure({required this.errMessage});
}

// final class AllRemindersSuccess extends ReminderState {
//   final List<ReminderModel> reminders;
//   AllRemindersSuccess({required this.reminders});
// }

// final class AllRemindersFailure extends ReminderState {
//   final String errMessage;
//   AllRemindersFailure({required this.errMessage});
// }

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

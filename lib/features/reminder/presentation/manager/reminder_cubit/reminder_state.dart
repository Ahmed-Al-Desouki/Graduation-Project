import 'package:meta/meta.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

// 🔴 تم إزالة extends Equatable
@immutable
sealed class ReminderState {}

final class ReminderInitial extends ReminderState {}

final class ReminderLoading extends ReminderState {}

// --- حالات إنشاء وتحديث ---
final class ReminderCreateSuccess extends ReminderState {
  final ReminderModel reminder;
  ReminderCreateSuccess({
    required this.reminder,
  }); // 💡 استخدمنا Named Parameter
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
    this.customs = const [],
  });
}

final class UpcomingRemindersFailure extends ReminderState {
  final String errMessage;
  UpcomingRemindersFailure({required this.errMessage});
}

// 🚀 الحالات الجديدة للحذف (Delete)
// ---------------------------------

final class ReminderDeleteLoading extends ReminderState {}

final class ReminderDeleteSuccess extends ReminderState {
  final String message;
  ReminderDeleteSuccess({required this.message});
}

final class ReminderDeleteFailure extends ReminderState {
  final String errMessage;
  ReminderDeleteFailure({required this.errMessage});
}

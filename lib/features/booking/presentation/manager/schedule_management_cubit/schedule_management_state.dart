part of 'schedule_management_cubit.dart';

@immutable
sealed class ScheduleManagementState {}

final class ScheduleManagementInitial extends ScheduleManagementState {}

// حالة التحميل (مثلاً عند الضغط على حفظ الجدول)
final class ScheduleManagementLoading extends ScheduleManagementState {}

// حالة نجاح حفظ الجدول (بعدها سننادي الـ Generate)
final class ScheduleCreatedSuccess extends ScheduleManagementState {
  final String scheduleId;
  ScheduleCreatedSuccess(this.scheduleId);
}

// حالة نجاح توليد المواعيد (هنا ننتقل لشاشة الكالندر)
final class SlotsGeneratedSuccess extends ScheduleManagementState {
  final String message;
  SlotsGeneratedSuccess(this.message);
}

// حالة الفشل
final class ScheduleManagementFailure extends ScheduleManagementState {
  final String errMessage;
  ScheduleManagementFailure(this.errMessage);
}

final class ScheduleFetchedSuccess extends ScheduleManagementState {
  final ScheduleEntity schedule;
  ScheduleFetchedSuccess(this.schedule);
}

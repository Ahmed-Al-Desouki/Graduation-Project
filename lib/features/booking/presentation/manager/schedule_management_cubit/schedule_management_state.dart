part of 'schedule_management_cubit.dart';

@immutable
sealed class ScheduleManagementState {}

final class ScheduleManagementInitial extends ScheduleManagementState {}

final class ScheduleManagementLoading extends ScheduleManagementState {}

final class ScheduleCreatedSuccess extends ScheduleManagementState {
  final String scheduleId;
  ScheduleCreatedSuccess(this.scheduleId);
}

final class SlotsGeneratedSuccess extends ScheduleManagementState {
  final String message;
  SlotsGeneratedSuccess(this.message);
}

final class ScheduleManagementFailure extends ScheduleManagementState {
  final String errMessage;
  ScheduleManagementFailure(this.errMessage);
}

final class ScheduleFetchedSuccess extends ScheduleManagementState {
  final ScheduleEntity schedule;
  ScheduleFetchedSuccess(this.schedule);
}

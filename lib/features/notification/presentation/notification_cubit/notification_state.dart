part of 'notification_cubit.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoadingMore extends NotificationState {
  final List<NotificationEntity> notifications;
  const NotificationLoadingMore(this.notifications);

  @override
  List<Object> get props => [notifications];
}

final class NotificationSuccess extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationSuccess(this.notifications);

  @override
  List<Object> get props => [notifications];
}

final class NotificationFailure extends NotificationState {
  final String error;

  const NotificationFailure(this.error);

  @override
  List<Object> get props => [error];
}

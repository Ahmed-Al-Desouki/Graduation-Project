import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? relatedEntityKey;
  final String? navigationTarget;
  final Map<String, dynamic>? navigationPayload;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
    this.relatedEntityKey,
    this.navigationTarget,
    this.navigationPayload,
  });

  @override
  List<Object?> get props => [id, isRead];
}

class NotificationsResultEntity {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int totalCount;
  final bool hasNextPage;

  NotificationsResultEntity({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    required this.hasNextPage,
  });
}

import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.relatedEntityType,
    super.relatedEntityId,
    super.relatedEntityKey,
    super.navigationTarget,
    super.navigationPayload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      message: json['message'] ?? "",
      type: json['type']?.toString() ?? "General",
      isRead: json['isRead'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt']).toLocal()
              : DateTime.now(),
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId']?.toString(),
      relatedEntityKey: json['relatedEntityKey']?.toString(),
      navigationTarget: json['navigationTarget']?.toString(),
      navigationPayload:
          json['navigationPayload'] is Map ? json['navigationPayload'] : {},
    );
  }
}

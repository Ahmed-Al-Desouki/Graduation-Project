import 'package:equatable/equatable.dart';

// تمثل الإشعار الواحد
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String
  type; // مثل: AppointmentUpdated, TicketUpdated, PrescriptionCreated
  final bool isRead;
  final DateTime createdAt;
  final String?
  relatedEntityType; // لنعرف هذا الإشعار يخص أي قسم (ticket, appointment, etc.)
  final String? relatedEntityId; // معرف الكيان المرتبط للذهاب إليه عند الضغط
  final String? relatedEntityKey; // 🚀 الحقل الجديد
  final String? navigationTarget; // 🚀 هدف التوجيه
  final Map<String, dynamic>? navigationPayload; // 🚀 البيانات الإضافية

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

// تمثل نتيجة جلب الإشعارات (للدعم الـ Pagination والـ Counter)
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

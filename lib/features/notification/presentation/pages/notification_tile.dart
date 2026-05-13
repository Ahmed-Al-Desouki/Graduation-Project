import 'package:flutter/material.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor:
          notification.isRead
              ? Colors.transparent
              : Colors.teal.withValues(alpha: 0.03),
      leading: _buildIcon(),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _timeAgo(notification.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      trailing:
          !notification.isRead
              ? const CircleAvatar(radius: 4, backgroundColor: Colors.teal)
              : null,
    );
  }

  Widget _buildIcon() {
    final IconData iconData = _getNotificationIcon(notification.type);
    final Color color = _getNotificationColor(notification.type);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'PrescriptionCreated':
        return Icons.medication_rounded;
      case 'ReviewRequested':
      case 'AppointmentCompleted':
        return Icons.rate_review_rounded;
      case 'MedicalRecordCreated':
        return Icons.assignment_ind_rounded;
      case 'PaymentSucceeded':
        return Icons.payments_rounded;
      case 'ReminderCreated':
      case 'ReminderUpdated':
        return Icons.notifications_active_rounded;
      case 'TicketResponse':
      case 'TicketClosed':
      case 'TicketUpdated':
        return Icons.support_agent_rounded;
      case 'AppointmentCreated':
      case 'AppointmentUpdated':
        return Icons.calendar_today_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'PrescriptionCreated':
        return Colors.green;
      case 'ReviewRequested':
        return Colors.amber;
      case 'PaymentSucceeded':
        return Colors.blue;
      case 'AppointmentCreated':
      case 'AppointmentUpdated':
        return Colors.blueAccent;
      case 'TicketUpdated':
      case 'TicketResponse':
        return Colors.orange;
      case 'ReminderCreated':
      case 'ReminderUpdated':
      case 'MedicalRecordCreated':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}

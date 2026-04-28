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
              : Colors.teal.withOpacity(0.03),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _timeAgo(notification.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      trailing:
          !notification.isRead
              ? const CircleAvatar(radius: 4, backgroundColor: Colors.teal)
              : null,
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case 'AppointmentCreated':
      case 'AppointmentUpdated':
        iconData = Icons.calendar_today;
        color = Colors.blue;
        break;
      case 'TicketUpdated':
        iconData = Icons.support_agent;
        color = Colors.orange;
        break;
      case 'PrescriptionCreated':
        iconData = Icons.medication;
        color = Colors.green;
        break;
      default:
        iconData = Icons.notifications_active;
        color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
    if (diff.inHours < 24) return "منذ ${diff.inHours} ساعة";
    return "منذ ${diff.inDays} يوم";
  }
}

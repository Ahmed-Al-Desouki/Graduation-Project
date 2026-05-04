import 'package:flutter/material.dart';
import '../../../domain/entities/slot_entity.dart';

class SlotCard extends StatelessWidget {
  final SlotEntity slot;
  final bool isPatientView;
  final bool isFollowUpMode;
  final VoidCallback? onBook;
  final VoidCallback? onDetails;
  final VoidCallback? onCancelByDoctor;
  final VoidCallback? onCancelByPatient;
  final VoidCallback? onBlock;
  final VoidCallback? onDelete;
  final VoidCallback? onBookFollowUp;
  final VoidCallback? unblock;

  const SlotCard({
    super.key,
    required this.slot,
    this.isPatientView = false,
    this.isFollowUpMode = false,
    this.onBook,
    this.onDetails,
    this.onDelete,
    this.onBlock,
    this.onCancelByDoctor,
    this.onCancelByPatient,
    this.onBookFollowUp,
    this.unblock,
  });

  @override
  Widget build(BuildContext context) {
    final String status = slot.status.trim().toLowerCase();
    final bool isAvailable = status == 'available';
    final bool isBooked = status == 'booked' || status == 'confirmed';
    final bool isCompleted = status == 'completed';
    final bool isBlocked = status == 'blocked';
    final bool isCancelled = status == 'cancelled';

    final Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTimeLeading(),
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(status),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(statusColor, status),
                ],
              ),
            ),
            _buildActions(
              isAvailable: isAvailable,
              isBooked: isBooked,
              isCompleted: isCompleted,
              isBlocked: isBlocked,
              isCancelled: isCancelled,
              context: context,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActions({
    required bool isAvailable,
    required bool isBooked,
    required bool isCompleted,
    required bool isBlocked,
    required bool isCancelled,
    required BuildContext context,
  }) {
    if (isPatientView) {
      if (isAvailable) {
        return ElevatedButton(
          onPressed: onBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Book",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return const SizedBox();
    }

    if (isAvailable) {
      if (isFollowUpMode) {
        return IconButton(
          onPressed: onBookFollowUp,
          icon: const Icon(Icons.add_task, color: Colors.orange),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onBlock,
            icon: const Icon(Icons.block, color: Color(0xFF94A3B8), size: 22),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
        ],
      );
    }

    if (isBlocked) {
      // لو السلوت معمول لها بلوك يدوي (مفيش موعد مرتبط بيها)
      if (slot.appointmentId == null) {
        return IconButton(
          onPressed: unblock, // 👈 الزرار الجديد
          icon: const Icon(
            Icons.settings_backup_restore_rounded,
            color: Colors.green,
            size: 24,
          ),
          tooltip: "Restore Slot",
        );
      } else {
        // 💡 لو فيه appointmentId يبقى دي اتعمل لها بلوك عشان الدكتور كنسل ميعاد هناك
        return Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Tooltip(
            message: "Blocked due to appointment cancellation",
            child: IconButton(
              onPressed: () {
                // إظهار رسالة توضيحية عند الضغط العادي
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Blocked due to appointment cancellation",
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Colors.orange,
                size: 22,
              ),
            ),
          ),
        );
      }
    }

    if (isBooked || isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDetails,
            icon: const Icon(
              Icons.visibility_outlined,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          if (!isCompleted)
            IconButton(
              onPressed: onCancelByDoctor,
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
        ],
      );
    }
    return const SizedBox();
  }

  String _getTitle(String status) {
    if (isPatientView) {
      if (status == 'available') return "Available Slot";
      if (status == 'blocked') return "Unavailable";
      if (status == 'completed') return "Past Session";
      return "Reserved";
    }
    if (status == 'available') return "No Patient Assigned";
    if (status == 'blocked') return "Time Blocked";
    return slot.patientName ?? "Reserved Session";
  }

  Widget _buildStatusBadge(Color color, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFF10B981);
      case 'booked':
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF8B5CF6);
      case 'blocked':
        return const Color(0xFF94A3B8);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.orange;
    }
  }

  Widget _buildTimeLeading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatOnlyTime(slot.startTime),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            _getAmPm(slot.startTime),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOnlyTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "${displayHour.toString().padLeft(2, '0')}:${parts[1]}";
    } catch (e) {
      return time;
    }
  }

  String _getAmPm(String time) {
    try {
      return int.parse(time.split(':')[0]) >= 12 ? "PM" : "AM";
    } catch (e) {
      return "";
    }
  }
}

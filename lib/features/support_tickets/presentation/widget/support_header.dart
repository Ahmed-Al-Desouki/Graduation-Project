// widgets/support_header.dart
import 'package:flutter/material.dart';

class SupportHeader extends StatelessWidget {
  final int urgentCount;
  const SupportHeader({super.key, required this.urgentCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Support Tickets",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and respond to user support requests.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        if (urgentCount > 0) _UrgentBadge(count: urgentCount),
      ],
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  final int count;
  const _UrgentBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // bg-status-urgent/10
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEF4444),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            "$count Urgent",
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

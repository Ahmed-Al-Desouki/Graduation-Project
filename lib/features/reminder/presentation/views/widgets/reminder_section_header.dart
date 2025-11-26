import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReminderSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isUpcoming;

  const ReminderSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isUpcoming ? const Color(0xFF0852F3) : const Color(0xFF23B82A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 13,
          backgroundColor: color,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ReminderSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isUpcoming;
  final Color? customColor;

  const ReminderSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.isUpcoming,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color finalColor;
    if (customColor != null) {
      finalColor = customColor!;
    } else if (isUpcoming) {
      finalColor = const Color(0xFF0852F3);
    } else {
      finalColor = const Color(0xFF23B82A);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 13,
          backgroundColor: finalColor,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

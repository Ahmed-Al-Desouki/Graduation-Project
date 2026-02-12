import 'package:flutter/material.dart';

class WorkingHourRow extends StatelessWidget {
  final String day;
  final String time;
  final bool isClosed;
  const WorkingHourRow({
    super.key,
    required this.day,
    required this.time,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(color: Colors.black54)),
          Text(
            time,
            style: TextStyle(
              color: isClosed ? Colors.red : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

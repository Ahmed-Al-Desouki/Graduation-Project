import 'package:flutter/material.dart';

class NextReminderCard extends StatelessWidget {
  const NextReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff66BB6A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Next Reminder",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Vitamin D Supplement",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Take 1 tablet with breakfast",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  "In 2 hours (8:00 AM)",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

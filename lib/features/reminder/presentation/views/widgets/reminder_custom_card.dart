import 'package:flutter/material.dart';

class ReminderCustomCard extends StatelessWidget {
  final String title, subtitle, time, next, date;

  const ReminderCustomCard({
    super.key,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.time,
    required this.next,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Next: $next',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.black45),
          ),
          const SizedBox(height: 6),
          Row(
            children: [Icon(Icons.calendar_month, size: 18, color: Colors.orange),
              SizedBox(width: 5),
              Text(date),
              SizedBox(width: 15),
              Icon(Icons.access_time_filled, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 5),
              Text('Time: $time',),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // هنا هتحط الـ Confirm أو Snooze لاحقًا
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text("Done"),
            ),
          ),
        ],
      ),
    );
  }
}
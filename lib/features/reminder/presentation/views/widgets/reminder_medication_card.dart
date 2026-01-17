import 'package:flutter/material.dart';

class ReminderMedicationCard extends StatelessWidget {
  final String title, subtitle, time, frequency, date;

  const ReminderMedicationCard({
    super.key,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.time,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFE6F6EA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.black45)),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 18, color: Colors.green),
              SizedBox(width: 5),
              Text(date),
              SizedBox(width: 15),
              Icon(
                Icons.access_time_filled,
                size: 18,
                color: Colors.green.shade700,
              ),
              SizedBox(width: 5),
              Text('Times: $time'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReminderAppointmentCard extends StatelessWidget {
  final String name, subtitle, date, time;

  const ReminderAppointmentCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffE8F7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 18, color: Colors.blue),
              SizedBox(width: 5),
              Text(date),
              SizedBox(width: 15),
              Icon(Icons.access_time_filled, size: 18, color: Colors.blue),
              SizedBox(width: 5),
              Text(time),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

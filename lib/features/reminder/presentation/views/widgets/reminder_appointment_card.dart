import 'package:flutter/material.dart';

class ReminderAppointmentCard extends StatelessWidget {
  final String name, specialization, date, time, statusText;
  final Color statusColor;
  final bool showCancel;

  const ReminderAppointmentCard({
    super.key,
    required this.name,
    required this.specialization,
    required this.date,
    required this.time,
    required this.statusText,
    required this.statusColor,
    this.showCancel = false,
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
          Text(specialization, style: const TextStyle(color: Colors.grey)),
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

          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

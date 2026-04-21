import 'package:flutter/material.dart';

class PatientAppointmentItem extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  const PatientAppointmentItem({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: Color(0xffE8F7F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctorName, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                specialty,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time_filled, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReminderMedicationCard extends StatelessWidget {
  final String title, subtitle, time, next, frequency, buttonText, date;
  final Color buttonColor;

  const ReminderMedicationCard({
    super.key,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.time,
    required this.next,
    required this.frequency,
    required this.buttonColor,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    if (buttonText == "Mark Taken") {
      cardColor = const Color(0xFFE6F6EA);
    } else if (buttonText == "Pending") {
      cardColor = const Color(0xFFF2F3F5);
    } else if (buttonText == "Take Now") {
      cardColor = const Color(0xFFFFF3E0);
    } else {
      cardColor = Colors.white;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Next: $next',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
          Text(subtitle, style: const TextStyle(color: Colors.black45)),
          const SizedBox(height: 6),
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
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: Text(buttonText, style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

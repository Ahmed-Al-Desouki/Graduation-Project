import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/day_schedule_item.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/day_settings_model.dart';

class WeeklyScheduleSection extends StatelessWidget {
  final List<DaySettings> weeklySettings;
  const WeeklyScheduleSection({super.key, required this.weeklySettings});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Working Hours",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenHeight * 0.02), // مسافة ريسبونسيف
        ...List.generate(7, (index) {
          return DayScheduleItem(
            dayName: _getDayName(index),
            settings: weeklySettings[index],
          );
        }),
      ],
    );
  }

  String _getDayName(int index) {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ][index];
  }
}

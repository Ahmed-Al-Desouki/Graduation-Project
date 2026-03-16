import 'package:flutter/material.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hour_row.dart';

class WorkingHoursSection extends StatelessWidget {
  const WorkingHoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Working Hours",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              WorkingHourRow(
                day: "Sunday",
                time: "11:00 AM - 7:00 PM",
                isClosed: false,
              ),
              SizedBox(height: 10),
              WorkingHourRow(
                day: "Monday",
                time: "9:00 AM - 6:00 PM",
                isClosed: false,
              ),
              SizedBox(height: 10),
              WorkingHourRow(day: "Tuesday", time: "Closed", isClosed: true),
              SizedBox(height: 10),
              WorkingHourRow(
                day: "Wednesday",
                time: "9:00 AM - 6:00 PM",
                isClosed: false,
              ),
              SizedBox(height: 10),
              WorkingHourRow(
                day: "Thursday",
                time: "9:00 AM - 6:00 PM",
                isClosed: false,
              ),
              SizedBox(height: 10),
              WorkingHourRow(
                day: "Friday",
                time: "9:00 AM - 4:00 PM",
                isClosed: false,
              ),
              SizedBox(height: 10),
              WorkingHourRow(day: "Saturday", time: "Closed", isClosed: true),
            ],
          ),
        ),
      ),
    );
  }
}

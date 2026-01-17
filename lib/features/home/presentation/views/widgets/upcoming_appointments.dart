import 'package:flutter/material.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/patient_appointment_Item.dart';

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Text(
                    "Upcoming Appointments",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(flex: 1),
                  Icon(
                    Icons.calendar_month,
                    color: Color.fromARGB(255, 8, 82, 243),
                  ),
                ],
              ),
            ),
            PatientAppointmentItem(
              doctorName: "Dr. Michael Chen",
              specialty: "Cardiologist",
              time: "Today, 2:30 PM",
              status: "Confirmed",
              statusColor: Colors.green,
              statusBgColor: Colors.green.shade100,
            ),
            PatientAppointmentItem(
              doctorName: "Dr. Lisa Rodriguez",
              specialty: "Dermatologist",
              time: "Tomorrow, 10:00 AM",
              status: "Scheduled",
              statusColor: Colors.blue,
              statusBgColor: Colors.blue.shade100,
            ),
          ],
        ),
      ),
    );
  }
}

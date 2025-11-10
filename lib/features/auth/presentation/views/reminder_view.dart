import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/data/models/reminder_model.dart';
import 'package:graduation_project/features/auth/presentation/views/add_reminder_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_appointment_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_medication_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_section_header.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  List<ReminderModel> medicationReminders = [];
List<ReminderModel> appointmentReminders = [];

  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ReminderHeader(),

            // Upcoming Appointments Title
            ReminderSectionHeader(
              title: 'Upcoming Appointments',
              count: 2,
              isUpcoming: true,
            ),
            const SizedBox(height: 10),

            for (var appt in appointmentReminders)
  ReminderAppointmentCard(
    name: appt.name,
    specialization: "Your data here",
    date: appt.startDate.toString(),
    time: appt.baseTime,
    statusText: "Scheduled",
    statusColor: Colors.blue,
  ),


            const SizedBox(height: 25),

            // Medication Reminders
            ReminderSectionHeader(
              title: 'Medication Reminders',
              count: 4,
              isUpcoming: false,
            ),
            const SizedBox(height: 10),

            for (var reminder in medicationReminders)
  ReminderMedicationCard(
    title: reminder.name,
    subtitle: "Your dosage info here", // ده هيتظبط من backend
    time: reminder.baseTime,
    next: reminder.baseTime,
    frequency: reminder.frequency,
    buttonColor: Colors.green,
    buttonText: "Mark Taken",
  ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: const [
                Color.fromARGB(255, 4, 249, 12),
                Color(0xFF1B4E8C),
              ],
              begin: isHovering ? Alignment.bottomRight : Alignment.topLeft,
              end: isHovering ? Alignment.topLeft : Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () async {
  final newReminder = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddReminderView()),
  );

  if (newReminder != null) {
    setState(() {
      if (newReminder.type == 'Medication') {
        medicationReminders.add(newReminder);
      } else if (newReminder.type == 'Appointment') {
        appointmentReminders.add(newReminder);
      }
    });
  }
},

            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

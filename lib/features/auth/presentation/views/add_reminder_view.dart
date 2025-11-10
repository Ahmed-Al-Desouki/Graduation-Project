import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/data/models/reminder_model.dart';

class AddReminderView extends StatefulWidget {
  const AddReminderView({super.key});

  @override
  State<AddReminderView> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  String frequency = 'Daily';
  String type = 'Medication';
  String baseTime = "08:00:00";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Reminder")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: messageController, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 20),

            DropdownButton<String>(
  value: type,
  onChanged: (val) {
    setState(() {
      type = val!;
    });
  },
  items: const [
    DropdownMenuItem(value: 'Medication', child: Text('Medication')),
    DropdownMenuItem(value: 'Appointment', child: Text('Appointment')),
    DropdownMenuItem(value: 'Custom', child: Text('Custom')),
  ],
),


            ElevatedButton(
              onPressed: () {
                final reminder = ReminderModel(
                  type: type,
                  name: nameController.text,
                  startDate: startDate,
                  endDate: endDate,
                  frequency: frequency,
                  intervalHours: frequency == 'EveryXHours' ? 6 : null,
                  baseTime: baseTime,
                  message: messageController.text,
                );

                Navigator.pop(context, reminder);
              },
              
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}

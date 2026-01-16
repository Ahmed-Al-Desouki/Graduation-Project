import 'package:flutter/material.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/shared_widgets.dart';

class ReminderTitleSection extends StatelessWidget {
  final String selectedType;
  final TextEditingController titleController;

  const ReminderTitleSection({
    super.key,
    required this.selectedType,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle("Reminder Title"),
        const SizedBox(height: 10),
        SectionCard(child: buildTitleField()),
      ],
    );
  }

  Widget buildTitleField() {
    String hint = "Reminder Title";
    IconData icon = Icons.edit;
    if (selectedType == 'Medication') {
      hint = "e.g. Panadol 500mg";
      icon = Icons.medication_liquid;
    } else if (selectedType == 'Appointment') {
      hint = "e.g. Dentist Checkup";
      icon = Icons.person;
    } else if (selectedType == 'Custom') {
      hint = "e.g. Check blood pressure";
      icon = Icons.notifications;
    }

    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}

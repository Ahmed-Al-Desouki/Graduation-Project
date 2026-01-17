import 'package:flutter/material.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/shared_widgets.dart';

class ReminderMessageSection extends StatelessWidget {
  final TextEditingController messageController;

  const ReminderMessageSection({super.key, required this.messageController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle("Message (Optional)"),
        const SizedBox(height: 10),
        SectionCard(child: buildMessageField()),
      ],
    );
  }

  Widget buildMessageField() {
    return TextField(
      controller: messageController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "e.g. Take with food...",
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

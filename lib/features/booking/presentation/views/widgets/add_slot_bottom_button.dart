import 'package:flutter/material.dart';

class AddSlotBottomButton extends StatelessWidget {
  final bool isFollowUp;
  final String selectedDayTitle;
  final VoidCallback onPressed;

  const AddSlotBottomButton({
    super.key,
    required this.isFollowUp,
    required this.selectedDayTitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isFollowUp ? Colors.orange : const Color(0xFF9333EA);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: Text(
          isFollowUp
              ? "Create Follow-up"
              : "Add Slot for ${selectedDayTitle.split(',')[0]}",
        ),
      ),
    );
  }
}

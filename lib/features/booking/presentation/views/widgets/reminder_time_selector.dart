import 'package:flutter/material.dart';

class ReminderTimeSelector extends StatelessWidget {
  final List<String> times;
  final Function(int) onPickTime;
  final Function(int) onDelete;
  final VoidCallback onAddTime;
  final bool showAddButton;

  const ReminderTimeSelector({
    super.key,
    required this.times,
    required this.onPickTime,
    required this.onDelete,
    required this.onAddTime,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children:
              times
                  .asMap()
                  .entries
                  .map(
                    (e) => InputChip(
                      onPressed: () => onPickTime(e.key),
                      label: Text(
                        e.value,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9333EA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onDeleted:
                          times.length > 1 ? () => onDelete(e.key) : null,
                      deleteIcon: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Color(0xFF9333EA),
                      ),
                      backgroundColor: Colors.purple.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF9333EA)),
                      ),
                    ),
                  )
                  .toList(),
        ),
        if (showAddButton)
          TextButton.icon(
            onPressed: onAddTime,
            icon: const Icon(Icons.add_alarm, size: 16),
            label: const Text("Add Time", style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

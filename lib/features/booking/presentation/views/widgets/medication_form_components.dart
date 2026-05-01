import 'package:flutter/material.dart';

class WeeklyDayPicker extends StatelessWidget {
  final List<int> selectedDays;
  final Function(int, bool) onSelected;

  const WeeklyDayPicker({
    super.key,
    required this.selectedDays,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Wrap(
      spacing: 6,
      children: List.generate(
        7,
        (i) => FilterChip(
          label: Text(
            days[i],
            style: TextStyle(
              fontSize: 11,
              color: selectedDays.contains(i) ? Colors.white : Colors.black,
            ),
          ),
          selected: selectedDays.contains(i),
          onSelected: (val) => onSelected(i, val),
          selectedColor: const Color(0xFF9333EA),
        ),
      ),
    );
  }
}

class MonthlyDayGrid extends StatelessWidget {
  final List<int> selectedDays;
  final Function(int) onToggle;

  const MonthlyDayGrid({
    super.key,
    required this.selectedDays,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(31, (i) {
        int day = i + 1;
        bool isSelected = selectedDays.contains(day);
        return InkWell(
          onTap: () => onToggle(day),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF9333EA) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF9333EA) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              "$day",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }
}

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

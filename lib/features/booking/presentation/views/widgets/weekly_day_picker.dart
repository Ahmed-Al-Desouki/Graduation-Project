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

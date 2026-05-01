import 'package:flutter/material.dart';

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

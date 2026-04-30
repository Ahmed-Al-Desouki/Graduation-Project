import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/day_slots_entity.dart';

class DoctorCalendarWidget extends StatelessWidget {
  final List<DaySlotsEntity> allDays;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final DateTime focusedDay;
  final Function(DateTime) onPageChanged;

  const DoctorCalendarWidget({
    super.key,
    required this.allDays,
    required this.selectedDay,
    required this.onDaySelected,
    required this.focusedDay,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      rowHeight: 45,
      calendarFormat: CalendarFormat.month,
      focusedDay: focusedDay,
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: (selected, focused) {
        onDaySelected(selected);
      },
      onPageChanged: (focused) {
        onPageChanged(focused);
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Color(0xFF9333EA),
          shape: BoxShape.circle,
        ),
      ),

      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, focusedDay) {
          final dayData =
              allDays.where((d) => isSameDay(d.date, day)).firstOrNull;
          if (dayData == null) return null;

          final Color color = dayData.stateColor;
          final bool isSelected = isSameDay(day, selectedDay);

          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.orange : color,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

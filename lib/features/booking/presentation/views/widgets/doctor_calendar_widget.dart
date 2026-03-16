import 'package:graduation_project/features/booking/presentation/manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        // لون اليوم المختار
        selectedDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        // لون اليوم الحالي (اللي طالع عندك بنفسجي)
        todayDecoration: const BoxDecoration(
          color: Color(0xFF9333EA),
          shape: BoxShape.circle,
        ),
      ),
      // ✅ تلوين الأيام ريسبونسيف بناءً على الداتا
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dayData =
              allDays
                  .where(
                    (d) =>
                        d.date.year == day.year &&
                        d.date.month == day.month &&
                        d.date.day == day.day,
                  )
                  .firstOrNull;

          if (dayData != null) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // بنفسجي لو محجوز بالكامل، أخضر لو متاح
                color:
                    dayData.isFullyBooked
                        ? Colors.purple.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: dayData.isFullyBooked ? Colors.purple : Colors.green,
                  width: 1,
                ),
              ),
              child: Center(child: Text('${day.day}')),
            );
          }
          return null;
        },
      ),

      // onDaySelected: (selectedDay, focusedDay) {
      //   // تحديث المواعيد المعروضة بالأسفل عند الضغط
      //   context.read<BookingCalendarCubit>().selectDate(selectedDay);
      // },
    );
  }
}

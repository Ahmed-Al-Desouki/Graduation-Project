import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart'; // ✅ لازم تضيف الـ import ده

part 'booking_calendar_state.dart';

class BookingCalendarCubit extends Cubit<BookingCalendarState> {
  final GetDoctorSlotsUseCase getDoctorSlotsUseCase;

  BookingCalendarCubit(this.getDoctorSlotsUseCase)
    : super(BookingCalendarInitial());

  Future<void> getMonthlyCalendar(
    String doctorId,
    DateTime start,
    DateTime end, {
    DateTime? targetDate,
  }) async {
    emit(BookingCalendarLoading());

    final result = await getDoctorSlotsUseCase(
      doctorId: doctorId,
      startDate: start,
      endDate: end,
    );

    result.fold((failure) => emit(BookingCalendarFailure(failure.errmessage)), (
      days,
    ) {
      final dateToShow = targetDate ?? DateTime.now();
      final todaySlots = _getSlotsForDate(days, dateToShow);

      emit(
        BookingCalendarSuccess(
          allDays: days,
          selectedDate: dateToShow,
          selectedDaySlots: todaySlots,
          selectedDayTitle: DateFormat('EEEE, d MMMM').format(dateToShow),
        ),
      );
    });
  }

  void selectDate(DateTime date) {
    if (state is BookingCalendarSuccess) {
      final currentState = state as BookingCalendarSuccess;
      final slots = _getSlotsForDate(currentState.allDays, date);

      emit(
        BookingCalendarSuccess(
          allDays: currentState.allDays,
          selectedDate: date,
          selectedDaySlots: slots,
          selectedDayTitle: DateFormat('EEEE, d MMMM').format(date),
        ),
      );
    }
  }

  List<SlotEntity> _getSlotsForDate(
    List<DaySlotsEntity> allDays,
    DateTime date,
  ) {
    try {
      return allDays
          .firstWhere(
            (day) =>
                day.date.year == date.year &&
                day.date.month == date.month &&
                day.date.day == date.day,
          )
          .slots;
    } catch (e) {
      return [];
    }
  }
}

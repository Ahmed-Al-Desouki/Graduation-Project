import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';
import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

part 'booking_calendar_state.dart';

class BookingCalendarCubit extends Cubit<BookingCalendarState> {
  final GetDoctorSlotsUseCase getDoctorSlotsUseCase;
  final SignalRService _signalRService;

  BookingCalendarCubit(this.getDoctorSlotsUseCase, this._signalRService)
    : super(BookingCalendarInitial());

  void listenToRealTimeUpdates() {
    _signalRService.on('SlotUpdated', (data) {
      log("📡 SignalR Data Received: $data");
      if (data != null && data.isNotEmpty) {
        final updatedSlotJson = data[0] as Map<String, dynamic>;
        final updatedSlot = SlotModel.fromJson(updatedSlotJson);

        _updateStateWithNewSlot(updatedSlot);
      }
    });
  }

  void _updateStateWithNewSlot(SlotEntity updatedSlot) {
    if (state is BookingCalendarSuccess) {
      final currentState = state as BookingCalendarSuccess;

      final newSelectedSlots =
          currentState.selectedDaySlots.map((slot) {
            return slot.slotId == updatedSlot.slotId ? updatedSlot : slot;
          }).toList();

      final newAllDays =
          currentState.allDays.map((day) {
            if (isSameDay(day.date, updatedSlot.date)) {
              final newSlots =
                  day.slots.map((s) {
                    return s.slotId == updatedSlot.slotId ? updatedSlot : s;
                  }).toList();
              return DaySlotsEntity(date: day.date, slots: newSlots);
            }
            return day;
          }).toList();

      emit(
        BookingCalendarSuccess(
          allDays: newAllDays,
          selectedDate: currentState.selectedDate,
          selectedDaySlots: newSelectedSlots,
          selectedDayTitle: currentState.selectedDayTitle,
        ),
      );
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

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

  @override
  Future<void> close() {
    _signalRService.off('SlotUpdated');
    return super.close();
  }
}

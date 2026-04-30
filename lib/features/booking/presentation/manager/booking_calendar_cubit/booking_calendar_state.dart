part of 'booking_calendar_cubit.dart';

@immutable
sealed class BookingCalendarState {}

final class BookingCalendarInitial extends BookingCalendarState {}

final class BookingCalendarLoading extends BookingCalendarState {}

final class BookingCalendarSuccess extends BookingCalendarState {
  final List<DaySlotsEntity> allDays;
  final DateTime selectedDate;
  final List<SlotEntity> selectedDaySlots;
  final String selectedDayTitle;

  BookingCalendarSuccess({
    required this.allDays,
    required this.selectedDate,
    required this.selectedDaySlots,
    required this.selectedDayTitle,
  });
}

final class BookingCalendarFailure extends BookingCalendarState {
  final String errMessage;
  BookingCalendarFailure(this.errMessage);
}

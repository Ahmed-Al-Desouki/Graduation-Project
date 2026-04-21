part of 'booking_calendar_cubit.dart';

@immutable
sealed class BookingCalendarState {}

final class BookingCalendarInitial extends BookingCalendarState {}

final class BookingCalendarLoading extends BookingCalendarState {}

final class BookingCalendarSuccess extends BookingCalendarState {
  // القائمة الكاملة للشهر (عشان Logic الألوان)
  final List<DaySlotsEntity> allDays;
  // اليوم المختار حالياً وقائمة المواعيد اللي فيه
  final DateTime selectedDate;
  final List<SlotEntity> selectedDaySlots;

  BookingCalendarSuccess({
    required this.allDays,
    required this.selectedDate,
    required this.selectedDaySlots,
  });
}

final class BookingCalendarFailure extends BookingCalendarState {
  final String errMessage;
  BookingCalendarFailure(this.errMessage);
}

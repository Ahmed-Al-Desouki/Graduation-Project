import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';
import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart'; // ✅ لازم تضيف الـ import ده

part 'booking_calendar_state.dart';

// class BookingCalendarCubit extends Cubit<BookingCalendarState> {
//   final GetDoctorSlotsUseCase getDoctorSlotsUseCase;

//   BookingCalendarCubit(this.getDoctorSlotsUseCase)
//     : super(BookingCalendarInitial());

//   Future<void> getMonthlyCalendar(
//     String doctorId,
//     DateTime start,
//     DateTime end, {
//     DateTime? targetDate,
//   }) async {
//     emit(BookingCalendarLoading());

//     final result = await getDoctorSlotsUseCase(
//       doctorId: doctorId,
//       startDate: start,
//       endDate: end,
//     );

//     result.fold((failure) => emit(BookingCalendarFailure(failure.errmessage)), (
//       days,
//     ) {
//       final dateToShow = targetDate ?? DateTime.now();
//       final todaySlots = _getSlotsForDate(days, dateToShow);

//       emit(
//         BookingCalendarSuccess(
//           allDays: days,
//           selectedDate: dateToShow,
//           selectedDaySlots: todaySlots,
//           selectedDayTitle: DateFormat('EEEE, d MMMM').format(dateToShow),
//         ),
//       );
//     });
//   }

//   void selectDate(DateTime date) {
//     if (state is BookingCalendarSuccess) {
//       final currentState = state as BookingCalendarSuccess;
//       final slots = _getSlotsForDate(currentState.allDays, date);

//       emit(
//         BookingCalendarSuccess(
//           allDays: currentState.allDays,
//           selectedDate: date,
//           selectedDaySlots: slots,
//           selectedDayTitle: DateFormat('EEEE, d MMMM').format(date),
//         ),
//       );
//     }
//   }

//   List<SlotEntity> _getSlotsForDate(
//     List<DaySlotsEntity> allDays,
//     DateTime date,
//   ) {
//     try {
//       return allDays
//           .firstWhere(
//             (day) =>
//                 day.date.year == date.year &&
//                 day.date.month == date.month &&
//                 day.date.day == date.day,
//           )
//           .slots;
//     } catch (e) {
//       return [];
//     }
//   }
// }

class BookingCalendarCubit extends Cubit<BookingCalendarState> {
  final GetDoctorSlotsUseCase getDoctorSlotsUseCase;
  final SignalRService _signalRService; // 👈 إضافة الخدمة هنا

  BookingCalendarCubit(this.getDoctorSlotsUseCase, this._signalRService)
    : super(BookingCalendarInitial());

  // 📡 ميثود لبدء الاستماع للتحديثات الحية
  void listenToRealTimeUpdates() {
    // افترضنا أن اسم الميثود من الباك إيند هو "ReceiveSlotUpdate"
    _signalRService.on('SlotUpdated', (data) {
      log("📡 SignalR Data Received: $data");
      if (data != null && data.isNotEmpty) {
        // تحويل البيانات القادمة من السيرفر إلى موديل (تأكد من توافق المسميات)
        final updatedSlotJson = data[0] as Map<String, dynamic>;
        final updatedSlot = SlotModel.fromJson(updatedSlotJson);

        _updateStateWithNewSlot(updatedSlot);
      }
    });
  }

  // ميثود لتحديث القوائم داخل الـ State الحالي
  void _updateStateWithNewSlot(SlotEntity updatedSlot) {
    if (state is BookingCalendarSuccess) {
      final currentState = state as BookingCalendarSuccess;

      // 1. تحديث السلوت داخل قائمة "اليوم المختار حالياً"
      final newSelectedSlots =
          currentState.selectedDaySlots.map((slot) {
            return slot.slotId == updatedSlot.slotId ? updatedSlot : slot;
          }).toList();

      // 2. تحديث السلوت داخل القائمة الكاملة (allDays) لضمان التزامن عند التنقل بين الأيام
      final newAllDays =
          currentState.allDays.map((day) {
            // نتحقق إذا كان هذا اليوم هو يوم السلوت المحدثة
            if (isSameDay(day.date, updatedSlot.date)) {
              final newSlots =
                  day.slots.map((s) {
                    return s.slotId == updatedSlot.slotId ? updatedSlot : s;
                  }).toList();
              return DaySlotsEntity(date: day.date, slots: newSlots);
            }
            return day;
          }).toList();

      // 🚀 إرسال الحالة الجديدة لتحديث الـ UI فوراً
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

  // ميثود مساعدة لمقارنة التاريخ
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

  // ... الميثودز القديمة (getMonthlyCalendar, selectDate) كما هي ...

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
    _signalRService.off('SlotUpdated'); // إغلاق الاستماع عند إغلاق الشاشة
    return super.close();
  }
}

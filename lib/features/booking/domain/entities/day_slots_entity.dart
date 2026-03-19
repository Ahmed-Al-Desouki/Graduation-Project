import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';

// class DaySlotsEntity {
//   final DateTime date;
//   final List<SlotEntity> slots;

//   DaySlotsEntity({required this.date, required this.slots});

//   // ✅ منطق تلوين الكالندر
//   // أخضر: يوجد مواعيد Available
//   bool get hasAvailableSlots => slots.any((s) => s.status == 'Available');
//   // بنفسجي: كل المواعيد Booked أو Completed
//   bool get isFullyBooked =>
//       slots.every((s) => s.status != 'Available' && s.status != 'Cancelled');
// }

class DaySlotsEntity {
  final DateTime date;
  final List<SlotEntity> slots;

  DaySlotsEntity({required this.date, required this.slots});

  // الأخضر: متاح للحجز
  bool get hasAvailableSlots => slots.any((s) => s.status == 'Available');

  // الرمادي: الدكتور قفل اليوم أو السلوتس محجوزة/ملغية/مبلكة
  bool get isFullyUnavailable => slots.every((s) => s.status != 'Available');
}

// day_slots_entity.dart
extension DaySlotsLogic on DaySlotsEntity {
  // هل اليوم كله مبلك؟
  bool get isFullyBlocked =>
      slots.isNotEmpty &&
      slots.every((s) => s.status.toLowerCase() == 'blocked');

  // هل اليوم كله محجوز؟
  bool get isFullyBooked =>
      slots.isNotEmpty &&
      slots.every(
        (s) =>
            s.status.toLowerCase() == 'booked' ||
            s.status.toLowerCase() == 'completed',
      );

  // هل يوجد مواعيد متاحة؟
  bool get hasAnyAvailable =>
      slots.any((s) => s.status.toLowerCase() == 'available');

  // تحديد اللون للكالندر
  Color get stateColor {
    if (isFullyBlocked) return Colors.grey.shade400;
    if (isFullyBooked) return const Color(0xFF3B82F6); // أزرق براند
    if (hasAnyAvailable) return const Color(0xFF10B981); // أخضر طبي
    return Colors.transparent;
  }
}

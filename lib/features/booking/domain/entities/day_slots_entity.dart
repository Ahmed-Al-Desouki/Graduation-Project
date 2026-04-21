import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';

class DaySlotsEntity {
  final DateTime date;
  final List<SlotEntity> slots;

  DaySlotsEntity({required this.date, required this.slots});

  // ✅ منطق تلوين الكالندر
  // أخضر: يوجد مواعيد Available
  bool get hasAvailableSlots => slots.any((s) => s.status == 'Available');
  // بنفسجي: كل المواعيد Booked أو Completed
  bool get isFullyBooked =>
      slots.every((s) => s.status != 'Available' && s.status != 'Cancelled');
}

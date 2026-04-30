import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';

class DaySlotsEntity {
  final DateTime date;
  final List<SlotEntity> slots;

  DaySlotsEntity({required this.date, required this.slots});

  bool get hasAvailableSlots => slots.any((s) => s.status == 'Available');

  bool get isFullyUnavailable => slots.every((s) => s.status != 'Available');
}

extension DaySlotsLogic on DaySlotsEntity {
  bool get isFullyBlocked =>
      slots.isNotEmpty &&
      slots.every((s) => s.status.toLowerCase() == 'blocked');

  bool get isFullyBooked =>
      slots.isNotEmpty &&
      slots.every(
        (s) =>
            s.status.toLowerCase() == 'booked' ||
            s.status.toLowerCase() == 'completed',
      );

  bool get hasAnyAvailable =>
      slots.any((s) => s.status.toLowerCase() == 'available');

  Color get stateColor {
    if (isFullyBlocked) return Colors.grey.shade400;
    if (isFullyBooked) return const Color(0xFF3B82F6);
    if (hasAnyAvailable) return const Color(0xFF10B981);
    return Colors.transparent;
  }
}

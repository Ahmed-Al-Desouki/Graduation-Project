// lib/features/booking/presentation/views/widgets/day_settings_model.dart
import 'package:flutter/material.dart';

class DaySettings {
  final int dayIndex;
  bool isEnabled;
  TimeOfDay startTime;
  TimeOfDay endTime;

  DaySettings({
    required this.dayIndex,
    this.isEnabled = false,
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 17, minute: 0),
  });
}

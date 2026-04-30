import 'dart:developer';

import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  ScheduleModel({
    required super.id,
    required super.templateName,
    required super.slotDurationMinutes,
    required super.bufferTimeMinutes,
    required super.effectiveFromDate,
    required super.effectiveToDate,
    required super.timeRanges,
  });

  factory ScheduleModel.fromV2List(List<dynamic> list) {
    if (list.isEmpty) {
      return ScheduleModel(
        id: '',
        templateName: 'Default',
        slotDurationMinutes: 30,
        bufferTimeMinutes: 5,
        effectiveFromDate: DateTime.now(),
        effectiveToDate: DateTime.now().add(const Duration(days: 90)),
        timeRanges: [],
      );
    }

    final firstDay = list.first;

    return ScheduleModel(
      id: 'active_config',
      templateName: 'My Working Hours',
      slotDurationMinutes: _toInt(firstDay['slotDurationMinutes']),
      bufferTimeMinutes: _toInt(firstDay['bufferTimeMinutes']),
      effectiveFromDate:
          DateTime.tryParse(firstDay['effectiveFromDate'] ?? "") ??
          DateTime.now(),
      effectiveToDate:
          DateTime.tryParse(firstDay['effectiveToDate'] ?? "") ??
          DateTime.now().add(const Duration(days: 180)),
      timeRanges: list.map((e) => TimeRangeModel.fromJson(e)).toList(),
    );
  }
}

class TimeRangeModel extends TimeRangeEntity {
  TimeRangeModel({
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
  });

  factory TimeRangeModel.fromJson(Map<String, dynamic> map) {
    log("DEBUG: Server Map Data: $map");

    return TimeRangeModel(
      dayOfWeek: _parseDayToIndex(map['dayOfWeek'] ?? map['day']),
      startTime: map['startTime'] ?? "09:00:00",
      endTime: map['endTime'] ?? "17:00:00",
    );
  }

  static int _parseDayToIndex(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'sunday':
          return 0;
        case 'monday':
          return 1;
        case 'tuesday':
          return 2;
        case 'wednesday':
          return 3;
        case 'thursday':
          return 4;
        case 'friday':
          return 5;
        case 'saturday':
          return 6;
        default:
          return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

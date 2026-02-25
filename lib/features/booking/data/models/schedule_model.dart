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

  factory ScheduleModel.fromJson(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      templateName: map['templateName'],
      slotDurationMinutes: map['slotDurationMinutes'],
      bufferTimeMinutes: map['bufferTimeMinutes'],
      effectiveFromDate: DateTime.parse(map['effectiveFromDate']),
      effectiveToDate: DateTime.parse(map['effectiveToDate']),
      timeRanges:
          (map['timeRanges'] as List)
              .map((e) => TimeRangeModel.fromJson(e))
              .toList(),
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
    return TimeRangeModel(
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}

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
    print(
      "Parsing field slotDuration: ${map['slotDurationMinutes'].runtimeType}",
    );
    return ScheduleModel(
      id: map['id'],
      templateName: map['templateName'],
      slotDurationMinutes: _toInt(map['slotDurationMinutes']),
      bufferTimeMinutes: _toInt(map['bufferTimeMinutes']),
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
      dayOfWeek: _parseDayToIndex(map['dayOfWeek']),
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  // 🛠️ دالة تحويل أيام الأسبوع من String لـ int
  static int _parseDayToIndex(dynamic value) {
    if (value is int) return value; // لو جاي رقم أصلاً

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
          // لو باعت رقم كـ String "1"
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

class ScheduleEntity {
  final String id;
  final String templateName;
  final int slotDurationMinutes;
  final int bufferTimeMinutes;
  final DateTime effectiveFromDate;
  final DateTime effectiveToDate;
  final List<TimeRangeEntity> timeRanges;

  ScheduleEntity({
    required this.id,
    required this.templateName,
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
    required this.effectiveFromDate,
    required this.effectiveToDate,
    required this.timeRanges,
  });
}

class TimeRangeEntity {
  final int dayOfWeek; // 0 for Sunday, 1 for Monday,.....
  final String startTime;
  final String endTime;
  final bool isActive;

  TimeRangeEntity({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });
}

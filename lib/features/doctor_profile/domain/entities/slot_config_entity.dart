class SlotConfigEntity {
  final String id;
  final String dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int bufferTimeMinutes;
  final bool isActive;
  final int estimatedSlotsPerDay;

  SlotConfigEntity({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
    required this.isActive,
    required this.estimatedSlotsPerDay,
  });
}

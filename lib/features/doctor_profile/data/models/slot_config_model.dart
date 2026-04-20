import '../../domain/entities/slot_config_entity.dart';

class SlotConfigModel extends SlotConfigEntity {
  SlotConfigModel({
    required super.id,
    required super.dayOfWeek,
    required super.dayName,
    required super.startTime,
    required super.endTime,
    required super.slotDurationMinutes,
    required super.bufferTimeMinutes,
    required super.isActive,
    required super.estimatedSlotsPerDay,
  });

  factory SlotConfigModel.fromJson(Map<String, dynamic> json) {
    return SlotConfigModel(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      dayName: json['dayName'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      slotDurationMinutes: json['slotDurationMinutes'],
      bufferTimeMinutes: json['bufferTimeMinutes'],
      isActive: json['isActive'],
      estimatedSlotsPerDay: json['estimatedSlotsPerDay'],
    );
  }
}

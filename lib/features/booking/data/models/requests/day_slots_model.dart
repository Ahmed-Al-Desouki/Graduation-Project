import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';

class SlotModel extends SlotEntity {
  SlotModel({
    required super.slotId,
    required super.date,
    required super.startTime,
    required super.status,
    super.patientName,
    super.appointmentId,
    super.patientNote,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      slotId: json['slotId'],
      date: DateTime.parse(json['slotDate']),
      startTime: json['startTime'],
      status: json['status'],
      patientName: json['patientFullName'],
      appointmentId: json['appointmentId'],
      patientNote: json['patientNotes'],
    );
  }
}

class DaySlotsModel extends DaySlotsEntity {
  DaySlotsModel({required super.date, required super.slots});

  factory DaySlotsModel.fromJson(Map<String, dynamic> json) {
    return DaySlotsModel(
      date: DateTime.parse(json['date']),
      slots: (json['slots'] as List).map((i) => SlotModel.fromJson(i)).toList(),
    );
  }
}

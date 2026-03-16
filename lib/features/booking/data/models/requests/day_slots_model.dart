import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';

// class DaySlotsModel extends DaySlotsEntity {
//   DaySlotsModel({required super.date, required super.slots});

//   factory DaySlotsModel.fromJson(Map<String, dynamic> json) {
//     return DaySlotsModel(
//       date: DateTime.parse(json['date']),
//       slots: (json['slots'] as List).map((i) => SlotModel.fromJson(i)).toList(),
//     );
//   }
// }

// class SlotModel extends SlotEntity {
//   // ... Constructor
//   SlotModel({
//     required super.slotId,
//     required super.startTime,
//     required super.status,
//     super.patientName,
//     super.appointmentId,
//   });
//   factory SlotModel.fromJson(Map<String, dynamic> json) {
//     return SlotModel(
//       slotId: json['slotId'],
//       startTime: json['startTime'],
//       status: json['status'],
//       patientName: json['patientFullName'],
//       appointmentId: json['appointmentId'],
//     );
//   }
// }

// slot_model.dart
class SlotModel extends SlotEntity {
  SlotModel({
    required super.slotId,
    required super.date, // ✅ تم إضافة التاريخ هنا
    required super.startTime,
    required super.status,
    super.patientName,
    super.appointmentId,
    super.patientNote, // تم إضافة الحقل الجديد
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      slotId: json['slotId'],
      date: DateTime.parse(json['slotDate']), // تحويل النص لتاريخ
      startTime: json['startTime'],
      status: json['status'],
      patientName: json['patientFullName'],
      appointmentId: json['appointmentId'],
      patientNote: json['patientNote'], // جلب الملاحظة من JSON
    );
  }
}

// day_slots_model.dart
class DaySlotsModel extends DaySlotsEntity {
  DaySlotsModel({required super.date, required super.slots});

  factory DaySlotsModel.fromJson(Map<String, dynamic> json) {
    return DaySlotsModel(
      date: DateTime.parse(json['date']),
      slots: (json['slots'] as List).map((i) => SlotModel.fromJson(i)).toList(),
    );
  }
}

// import '../../domain/entities/medication_item_entity.dart';

// class MedicationItemModel extends MedicationItemEntity {
//   MedicationItemModel({
//     super.itemId,
//     required super.medicationName,
//     required super.dosage,
//     required super.frequency,
//     required super.duration,
//     required super.quantity,
//     super.instructions,
//     required super.reminderFrequencyType,
//     super.reminderWeeklyDays,
//     super.reminderDailyDoseTimes,
//     super.reminderIntervalHours,
//     required super.reminderStartDate,
//     super.reminderEndDate,
//     super.reminderFirstDoseTime,
//   });

//   factory MedicationItemModel.fromJson(Map<String, dynamic> json) {
//     return MedicationItemModel(
//       itemId: json['itemId']?.toString(),
//       medicationName: json['medicationName']?.toString() ?? '',
//       dosage: json['dosage']?.toString() ?? '',
//       frequency: json['frequency']?.toString() ?? '',
//       duration: json['duration']?.toString() ?? '',
//       quantity:
//           json['quantity'] is int
//               ? json['quantity']
//               : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
//       instructions: json['instructions']?.toString() ?? '',
//       reminderFrequencyType: json['reminderFrequencyType'] ?? 0,
//       reminderWeeklyDays:
//           json['reminderWeeklyDays'] != null
//               ? List<int>.from(json['reminderWeeklyDays'])
//               : [],
//       reminderDailyDoseTimes:
//           json['reminderDailyDoseTimes'] != null
//               ? List<String>.from(json['reminderDailyDoseTimes'])
//               : [],
//       reminderIntervalHours: json['reminderIntervalHours'],
//       // ✅ تحصين التواريخ (مهم جداً)
//       reminderStartDate:
//           json['reminderStartDate'] != null
//               ? DateTime.parse(json['reminderStartDate'])
//               : DateTime.now(),
//       reminderEndDate:
//           json['reminderEndDate'] != null
//               ? DateTime.parse(json['reminderEndDate'])
//               : null,
//       reminderFirstDoseTime: json['reminderFirstDoseTime']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'medicationName': medicationName,
//       'dosage': dosage,
//       'frequency': frequency,
//       'duration': duration,
//       'quantity': quantity,
//       'instructions': instructions ?? "N/A",
//       'reminderFrequencyType': reminderFrequencyType,
//       'reminderWeeklyDays': reminderWeeklyDays ?? [],
//       'reminderDailyDoseTimes': reminderDailyDoseTimes ?? [],
//       'reminderIntervalHours': reminderIntervalHours,
//       // ✅ تنظيف التاريخ من الميكروثانية (Split عند النقطة)
//       'reminderStartDate': reminderStartDate.toIso8601String().split('.')[0],
//       'reminderEndDate': reminderEndDate?.toIso8601String().split('.')[0],
//       'reminderFirstDoseTime': reminderFirstDoseTime,
//     };
//   }
// }

import '../../domain/entities/medication_item_entity.dart';

class MedicationItemModel extends MedicationItemEntity {
  MedicationItemModel({
    super.itemId,
    required super.medicationName,
    required super.dosage,
    required super.frequency,
    required super.duration,
    required super.quantity,
    super.instructions,
    required super.reminderFrequencyType,
    super.reminderWeeklyDays,
    super.reminderDailyDoseTimes,
    super.reminderIntervalHours,
    required super.reminderStartDate,
    super.reminderEndDate,
    super.reminderFirstDoseTime,
  });

  factory MedicationItemModel.fromJson(Map<String, dynamic> json) {
    return MedicationItemModel(
      itemId: json['itemId']?.toString(),
      medicationName: json['medicationName']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      quantity:
          json['quantity'] is int
              ? json['quantity']
              : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      instructions: json['instructions']?.toString() ?? '',
      reminderFrequencyType: json['reminderFrequencyType'] ?? 0,
      reminderWeeklyDays:
          json['reminderWeeklyDays'] != null
              ? List<int>.from(json['reminderWeeklyDays'])
              : null, // خليه null لو مش موجود
      reminderDailyDoseTimes:
          json['reminderDailyDoseTimes'] != null
              ? List<String>.from(json['reminderDailyDoseTimes'])
              : [],
      reminderIntervalHours: json['reminderIntervalHours'],
      reminderStartDate:
          json['reminderStartDate'] != null
              ? DateTime.parse(json['reminderStartDate'])
              : DateTime.now(),
      reminderEndDate:
          json['reminderEndDate'] != null
              ? DateTime.parse(json['reminderEndDate'])
              : null,
      reminderFirstDoseTime: json['reminderFirstDoseTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // 1. الحقول الأساسية اللي موجودة في كل الأنواع
    final Map<String, dynamic> data = {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration, // تأكد إنك باعتها "1 day" للـ Once
      'quantity': quantity,
      'instructions': instructions ?? "",
      'reminderFrequencyType': reminderFrequencyType,
      'reminderStartDate': reminderStartDate.toIso8601String().split('.')[0],
      'reminderDailyDoseTimes': reminderDailyDoseTimes ?? [],
    };

    // 2. ✅ السر هنا: الحقول دي تتبعت "فقط" لو فيها قيمة (مش null)
    // ده اللي الباك-إيند طالبه بالظبط في المثال اللي بعتهولك

    if (reminderWeeklyDays != null && reminderWeeklyDays!.isNotEmpty) {
      data['reminderWeeklyDays'] = reminderWeeklyDays;
    }

    if (reminderEndDate != null) {
      data['reminderEndDate'] =
          reminderEndDate!.toIso8601String().split('.')[0];
    }

    if (reminderIntervalHours != null) {
      data['reminderIntervalHours'] = reminderIntervalHours;
    }

    if (reminderFirstDoseTime != null) {
      data['reminderFirstDoseTime'] = reminderFirstDoseTime;
    }

    return data;
  }
}

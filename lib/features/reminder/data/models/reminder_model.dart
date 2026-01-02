// class ReminderModel {
//   final String type;
//   final String name;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String frequency;
//   final int? intervalHours;
//   final String baseTime;
//   final String? message;

//   ReminderModel({
//     required this.type,
//     required this.name,
//     required this.startDate,
//     required this.endDate,
//     required this.frequency,
//     this.intervalHours,
//     required this.baseTime,
//     this.message,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "type": type,
//       "name": name,
//       "startDate": startDate.toUtc().toIso8601String(),
//       "endDate": endDate.toUtc().toIso8601String(),
//       "frequency": frequency,
//       "intervalHours": intervalHours,
//       "baseTime": baseTime,
//       "message": message,
//     };
//   }
// }
// -----------------------------------------------------------------
class ReminderModel {
  final String type;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? message;
  final int patientID;
  final bool isActive;
  final String status;
  final int? prescriptionMedID;
  final String? dosage;
  final String? reminderID;
  final String? rrule;
  final SimpleModel? simple;
  final String timeZoneId;

  ReminderModel({
    required this.type,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.message,
    required this.patientID,
    this.isActive = true,
    this.status = "Pending",
    this.prescriptionMedID,
    this.dosage,
    this.reminderID,
    this.rrule,
    this.simple,
    this.timeZoneId = "Africa/Cairo",
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "title": title,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "message": message,
      // "status": status,
      // "isActive": isActive,
      if (rrule != null) "rrule": rrule,
      if (simple != null) "simple": simple!.toJson(),
      "prescriptionMedID": prescriptionMedID,
      "dosage": dosage,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      patientID:
          json['patientID'] is String
              ? int.parse(json['patientID'])
              : (json['patientID'] ?? 0),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      message: json['message'],
      status: json['status'] ?? 'Pending',
      isActive: json['isActive'] ?? true,
      prescriptionMedID: json['prescriptionMedID'],
      dosage: json['dosage'],
      rrule: json['rrule'],
      simple: json['simple'] != null
          ? SimpleModel.fromJson(json['simple'])
          : null,
    timeZoneId: json['timeZoneId'] ?? 'Africa/Cairo',
    );
  }
}

class SimpleModel {
  final int intervalHours;
  final String firstDoseTime;     // "08:00"  (بدون ثواني)

  SimpleModel({
    required this.intervalHours,
    required this.firstDoseTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "frequency": "EveryXHours",
      "intervalHours": intervalHours,
      "times": [firstDoseTime],     // السيرفيس بيتوقع array حتى لو عنصر واحد
    };
  }

  factory SimpleModel.fromJson(Map<String, dynamic> json) {
    final times = (json['times'] as List<dynamic>?) ?? [];
    return SimpleModel(
      intervalHours: json['intervalHours'] ?? 8,
      firstDoseTime: times.isNotEmpty ? times.first.toString() : "08:00",
    );
  }
}

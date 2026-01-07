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
// class ReminderModel {
//   final String type;
//   final String title;
//   final DateTime startDate;
//   final DateTime? endDate;
//   final String? message;
//   final int patientID;
//   final bool isActive;
//   final String status;
//   final int? prescriptionMedID;
//   final String? dosage;
//   final String? reminderId;
//   final String? rrule;
//   final SimpleModel? simple;
//   final String timeZoneId;

//   ReminderModel({
//     required this.type,
//     required this.title,
//     required this.startDate,
//     this.endDate,
//     this.message,
//     required this.patientID,
//     this.isActive = true,
//     this.status = "Pending",
//     this.prescriptionMedID,
//     this.dosage,
//     this.reminderId,
//     this.rrule,
//     this.simple,
//     this.timeZoneId = "Africa/Cairo",
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "type": type,
//       "title": title,
//       "startDate": startDate.toIso8601String(),
//       if (endDate != null) "endDate": endDate!.toIso8601String(),
//       "message": message,
//       // "status": status,
//       // "isActive": isActive,
//       if (rrule != null) "rrule": rrule,
//       if (simple != null) "simple": simple!.toJson(),
//       "prescriptionMedID": prescriptionMedID,
//       "dosage": dosage,
//     };
//   }

//   factory ReminderModel.fromJson(Map<String, dynamic> json) {
//     return ReminderModel(
//       reminderId: json['id']?.toString() ?? json['reminderId']?.toString() ?? json['reminderID']?.toString(),
//       patientID:
//           json['patientId'] is String
//               ? int.parse(json['patientId'])
//               : (json['patientId'] ?? 0),
//       type: json['type'] ?? '',
//       title: json['title'] ?? '',
//       startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
//       endDate: json['endDate'] != null 
//           ? DateTime.tryParse(json['endDate']) 
//           : null,
//       message: json['message'],
//       status: json['status'] ?? 'Pending',
//       isActive: json['isActive'] ?? true,
//       prescriptionMedID: json['prescriptionMedID'],
//       dosage: json['dosage'],
//       rrule: json['rrule'],
//       simple: json['simple'] != null
//           ? SimpleModel.fromJson(json['simple'])
//           : null,
//     timeZoneId: json['timeZoneId'] ?? 'Africa/Cairo',
//     );
//   }
// }
class ReminderModel {
  final String type;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? message;
  final int patientID;
  final bool isActive;
  final String status;
  final int? prescriptionMedID;
  final String? dosage;
  final String? reminderId;
  final String? rrule;
  final SimpleModel? simple;
  final String timeZoneId;
  final bool isSimpleEveryXHours;

  ReminderModel({
    required this.type,
    required this.title,
    required this.startDate,
    this.endDate,
    this.message,
    required this.patientID,
    this.isActive = true,
    this.status = "Pending",
    this.prescriptionMedID,
    this.dosage,
    this.reminderId,
    this.rrule,
    this.simple,
    this.timeZoneId = "Africa/Cairo",
    this.isSimpleEveryXHours = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "title": title,
      "startDate": startDate.toIso8601String(),
      if (endDate != null) "endDate": endDate!.toIso8601String(),
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
    print("DEBUG: JSON simple = ${json['simple']}");
    SimpleModel? parsedSimple;
  if (json['isSimpleEveryXHours'] == true) {
    // ✅ بناء SimpleModel يدويًا من الحقول المباشرة
    parsedSimple = SimpleModel(
      intervalHours: json['intervalHours'] ?? 8,
      firstDoseTime: json['firstDoseTime'] ?? "08:00",
    );
  } else if (json['simple'] != null) {
    // الـ fallback لو السيرفر رجع simple كـ object (لو تغير في المستقبل)
    parsedSimple = SimpleModel.fromJson(json['simple']);
  }
  // ✅ تعديل: استخدم DateTime.parse ثم toLocal() فقط لو الـ string مع Z (UTC)، غير كده خليها local
  DateTime parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    final parsed = DateTime.tryParse(dateStr) ?? DateTime.now();
    if (!dateStr.endsWith('Z')) {
      // ✅ الحل: أضف +2 ساعات يدويًا لـ EET لو بدون Z (لأن parsed بيفترض UTC)
      return parsed.add(const Duration(hours: 2));
    }
    return parsed.toLocal(); // لو Z، حوّل طبيعي
  }

  return ReminderModel(
    reminderId: json['id']?.toString() ?? json['reminderId']?.toString() ?? json['reminderID']?.toString(),
    patientID: json['patientId'] is String ? int.parse(json['patientId']) : (json['patientId'] ?? 0),
    type: json['type'] ?? '',
    title: json['title'] ?? '',
    startDate: parseDate(json['startDate']),
    endDate: json['endDate'] != null ? parseDate(json['endDate']) : null,
    message: json['message'],
    status: json['status'] ?? 'Pending',
    isActive: json['isActive'] ?? true,
    prescriptionMedID: json['prescriptionMedID'],
    dosage: json['dosage'],
    rrule: json['rrule'],
    simple: parsedSimple, // ✅ استخدم الـ parsedSimple اللي بنيناه
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

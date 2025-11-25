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
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency;
  final int? intervalHours;
  final String baseTime;
  final String? message;
  final int patientID;
  final bool isActive;
  final String status;
  final int? prescriptionMedID;
  final String? dosage;

  ReminderModel({
    required this.type,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    this.intervalHours,
    required this.baseTime,
    this.message,
    required this.patientID,
    this.isActive = true,
    this.status = "Pending",
    this.prescriptionMedID,
    this.dosage,
  });

  Map<String, dynamic> toJson() {
    return {
      "patientID": patientID,
      "type": type,
      "name": name,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "frequency": frequency,
      "intervalHours": intervalHours,
      "baseTime": baseTime,
      "message": message,
      "status": status,
      "isActive": isActive,
      "prescriptionMedID": prescriptionMedID,
      "dosage": dosage,
    };
  }
}

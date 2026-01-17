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
      if (rrule != null) "rrule": rrule,
      if (simple != null) "simple": simple!.toJson(),
      "prescriptionMedID": prescriptionMedID,
      "dosage": dosage,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    SimpleModel? parsedSimple;
    if (json['isSimpleEveryXHours'] == true) {
      parsedSimple = SimpleModel(
        intervalHours: json['intervalHours'] ?? 8,
        firstDoseTime: json['firstDoseTime'] ?? "08:00",
      );
    } else if (json['simple'] != null) {
      parsedSimple = SimpleModel.fromJson(json['simple']);
    }
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      final parsed = DateTime.tryParse(dateStr) ?? DateTime.now();
      if (!dateStr.endsWith('Z')) {
        return parsed.add(const Duration(hours: 2));
      }
      return parsed.toLocal();
    }

    return ReminderModel(
      reminderId:
          json['id']?.toString() ??
          json['reminderId']?.toString() ??
          json['reminderID']?.toString(),
      patientID:
          json['patientId'] is String
              ? int.parse(json['patientId'])
              : (json['patientId'] ?? 0),
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
      simple: parsedSimple,
      timeZoneId: json['timeZoneId'] ?? 'Africa/Cairo',
    );
  }
}

class SimpleModel {
  final int intervalHours;
  final String firstDoseTime;

  SimpleModel({required this.intervalHours, required this.firstDoseTime});

  Map<String, dynamic> toJson() {
    return {
      "frequency": "EveryXHours",
      "intervalHours": intervalHours,
      "times": [firstDoseTime],
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

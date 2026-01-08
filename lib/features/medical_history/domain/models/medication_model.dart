class MedicationModel {
  final int? patientId;
  final int? currentMedicationID;
  final int historyID;
  final String medicationName;
  final String dosage;
  final String doseInstruction;
  final String? startDate;
  final String? endDate;
  final String? notes;

  // ✅ 1. خاصية جديدة لتحديد المصدر
  final bool isSelfMedication;

  MedicationModel({
    this.patientId,
    this.currentMedicationID,
    required this.historyID,
    required this.medicationName,
    required this.dosage,
    required this.doseInstruction,
    this.startDate,
    this.endDate,
    this.notes,
    this.isSelfMedication = false, // الافتراضي false (يعني دكتور)
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      currentMedicationID: json['currentMedicationID'] ?? json['id'],
      historyID: json['historyID'] ?? 0,
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      doseInstruction: json['doseinstruction'] ?? json['instructions'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
      notes: json['notes'],
      // هنا مش بنقرأ isSelfMedication من الـ JSON لأنها مش جاية من الباك
      // هنظبطها في الموديل الكبير
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'patientId': patientId,
      'historyID': historyID,
      'medicationName': medicationName,
      'dosage': dosage,
      // لاحظ: الباك إيند بيسميها instructions في الـ Self Med
      // و doseinstruction في الـ Prescription (بس الـ Prescription read-only غالباً)
      // لتوحيد الإرسال، هنبعت الاتنين أو نعتمد على اللي الباك إيند عايزه في الـ Upsert
      'instructions': doseInstruction,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
    };

    // ✅ التعديل الجوهري هنا:
    if (currentMedicationID != null) {
      data['selfMedicationID'] = currentMedicationID;
    }

    return data;
  }

  // ✅ 2. دالة copyWith عشان نغير قيمة isSelfMedication بسهولة
  MedicationModel copyWith({bool? isSelfMedication}) {
    return MedicationModel(
      currentMedicationID: currentMedicationID,
      historyID: historyID,
      medicationName: medicationName,
      dosage: dosage,
      doseInstruction: doseInstruction,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      isSelfMedication: isSelfMedication ?? this.isSelfMedication,
    );
  }
}

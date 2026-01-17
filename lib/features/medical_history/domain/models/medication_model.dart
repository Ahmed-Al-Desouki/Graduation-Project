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
    this.isSelfMedication = false,
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
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'patientId': patientId,
      'historyID': historyID,
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': doseInstruction,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
    };

    if (currentMedicationID != null) {
      data['selfMedicationID'] = currentMedicationID;
    }

    return data;
  }

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

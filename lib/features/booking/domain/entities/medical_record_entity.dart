class MedicalRecordEntity {
  final String? id;
  final String chiefComplaint;
  final String vitalSigns;
  final String physicalExamination;
  final String diagnosis;
  final String diagnosisCode;
  final String treatmentPlan;
  final String doctorNotes;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final String followUpInstructions;

  MedicalRecordEntity({
    this.id,
    required this.chiefComplaint,
    required this.vitalSigns,
    required this.physicalExamination,
    required this.diagnosis,
    required this.diagnosisCode,
    required this.treatmentPlan,
    required this.doctorNotes,
    required this.followUpRequired,
    this.followUpDate,
    required this.followUpInstructions,
  });
}

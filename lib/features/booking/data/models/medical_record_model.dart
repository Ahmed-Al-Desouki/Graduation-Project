import '../../domain/entities/medical_record_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  MedicalRecordModel({
    super.id,
    required super.chiefComplaint,
    required super.vitalSigns,
    required super.physicalExamination,
    required super.diagnosis,
    required super.diagnosisCode,
    required super.treatmentPlan,
    required super.doctorNotes,
    required super.followUpRequired,
    super.followUpDate,
    required super.followUpInstructions,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      chiefComplaint: json['chiefComplaint'] ?? '',
      vitalSigns: json['vitalSigns'] ?? '',
      physicalExamination: json['physicalExamination'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      diagnosisCode: json['diagnosisCode'] ?? '',
      treatmentPlan: json['treatmentPlan'] ?? '',
      doctorNotes: json['doctorNotes'] ?? '',
      followUpRequired: json['followUpRequired'] ?? false,
      followUpDate:
          json['followUpDate'] != null
              ? DateTime.parse(json['followUpDate'])
              : null,
      followUpInstructions: json['followUpInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chiefComplaint': chiefComplaint,
      'vitalSigns': vitalSigns,
      'physicalExamination': physicalExamination,
      'diagnosis': diagnosis,
      'diagnosisCode': diagnosisCode,
      'treatmentPlan': treatmentPlan,
      'doctorNotes': doctorNotes,
      'followUpRequired': followUpRequired,
      // 'followUpDate': followUpDate?.toIso8601String(),
      'followUpDate': followUpDate?.toIso8601String().split('T')[0],
      'followUpInstructions': followUpInstructions,
    };
  }
}

class MedicalRecordEntity {
  final String? id; // الـ ID اللي بيرجع من الـ POST
  final String chiefComplaint; // شكوى المريض
  final String vitalSigns; // العلامات الحيوية (الضغط، الحرارة..)
  final String physicalExamination; // الفحص الظاهري
  final String diagnosis; // التشخيص
  final String diagnosisCode; // كود المرض (ICD-10)
  final String treatmentPlan; // خطة العلاج
  final String doctorNotes; // ملاحظات الطبيب
  final bool followUpRequired; // هل يحتاج متابعة؟
  final DateTime? followUpDate; // تاريخ المتابعة
  final String followUpInstructions; // تعليمات المتابعة

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

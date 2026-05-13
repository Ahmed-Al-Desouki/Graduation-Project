import 'package:flutter/material.dart';
import 'custom_medical_text_field.dart';

class MedicalRecordForm extends StatelessWidget {
  final bool canEdit;
  final TextEditingController chiefComplaintController;
  final TextEditingController vitalsController;
  final TextEditingController physicalExamController;
  final TextEditingController diagnosisController;
  final TextEditingController diagnosisCodeController;
  final TextEditingController treatmentPlanController;
  final TextEditingController doctorNotesController;

  const MedicalRecordForm({
    super.key,
    required this.canEdit,
    required this.chiefComplaintController,
    required this.vitalsController,
    required this.physicalExamController,
    required this.diagnosisController,
    required this.diagnosisCodeController,
    required this.treatmentPlanController,
    required this.doctorNotesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomMedicalTextField(
          controller: chiefComplaintController,
          label: "Chief Complaint",
          icon: Icons.sick_outlined,
          maxLines: 2,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: vitalsController,
          label: "Vital Signs",
          icon: Icons.monitor_heart_outlined,
          maxLines: 2,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: physicalExamController,
          label: "Physical Examination",
          icon: Icons.accessibility_new,
          maxLines: 3,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: diagnosisController,
          label: "Final Diagnosis *",
          icon: Icons.fact_check,
          maxLines: 2,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: diagnosisCodeController,
          label: "Diagnosis Code (ICD-10)",
          icon: Icons.qr_code,
          maxLines: 1,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: treatmentPlanController,
          label: "Treatment Plan",
          icon: Icons.event_note,
          maxLines: 8,
          enabled: canEdit,
        ),
        CustomMedicalTextField(
          controller: doctorNotesController,
          label: "Internal Doctor Notes",
          icon: Icons.note_alt,
          maxLines: 4,
          enabled: canEdit,
        ),
      ],
    );
  }
}

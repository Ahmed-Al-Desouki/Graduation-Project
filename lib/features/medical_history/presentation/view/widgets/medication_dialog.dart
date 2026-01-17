import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_dialog_layout.dart';
import 'package:intl/intl.dart';

class MedicationDialog {
  static void show(
    BuildContext context,
    int historyId,
    PatientProfileCubit cubit, {
    MedicationModel? medToEdit,
  }) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: medToEdit?.medicationName ?? '',
    );
    final dosageController = TextEditingController(
      text: medToEdit?.dosage ?? '',
    );
    final instructionController = TextEditingController(
      text: medToEdit?.doseInstruction ?? '',
    );
    final startDateController = TextEditingController(
      text: medToEdit?.startDate?.split('T')[0] ?? '',
    );
    final endDateController = TextEditingController(
      text: medToEdit?.endDate?.split('T')[0] ?? '',
    );

    Future<void> pickDate(TextEditingController controller) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => MedicalDialogLayout(
            title: medToEdit == null ? "Add Medication" : "Edit Medication",
            themeColor: const Color(0xFF9C27B0),
            formKey: formKey,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                final String? userIdStr = await SecureStorageHelper.getUserId();
                final int userId = int.tryParse(userIdStr ?? '') ?? 0;

                cubit.addOrUpdateMedication(
                  MedicationModel(
                    patientId: userId,
                    currentMedicationID: medToEdit?.currentMedicationID,
                    historyID: historyId,
                    medicationName: nameController.text,
                    dosage: dosageController.text,
                    doseInstruction: instructionController.text,
                    startDate:
                        startDateController.text.isNotEmpty
                            ? "${startDateController.text}T00:00:00Z"
                            : null,
                    endDate:
                        endDateController.text.isNotEmpty
                            ? "${endDateController.text}T00:00:00Z"
                            : null,
                    notes: medToEdit?.notes,
                    isSelfMedication: true,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MedicalTextField(
                  controller: nameController,
                  label: "Medication Name",
                  isRequired: true,
                  icon: Icons.medication,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MedicalTextField(
                        controller: dosageController,
                        label: "Dosage",
                        hint: "500mg",
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MedicalTextField(
                        controller: instructionController,
                        label: "Instruction",
                        hint: "Daily",
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: MedicalTextField(
                        controller: startDateController,
                        label: "Start Date",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        isRequired: true,
                        onTap: () => pickDate(startDateController),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MedicalTextField(
                        controller: endDateController,
                        label: "End Date",
                        icon: Icons.event,
                        readOnly: true,
                        onTap: () => pickDate(endDateController),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_dialog_layout.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';

class FamilyHistoryDialog {
  static void show(
    BuildContext context,
    int historyId,
    PatientProfileCubit cubit, {
    FamilyHistoryModel? itemToEdit,
  }) {
    final formKey = GlobalKey<FormState>();
    final conditionController = TextEditingController(
      text: itemToEdit?.condition ?? '',
    );
    final relativeController = TextEditingController(
      text: itemToEdit?.relative ?? '',
    );
    final ageController = TextEditingController(
      text: itemToEdit?.onsetAge?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: itemToEdit?.notes ?? '',
    );
    bool isVerified = itemToEdit?.isVerified ?? false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => MedicalDialogLayout(
                  title: itemToEdit == null ? "Add Record" : "Edit Record",
                  themeColor: const Color(0xFFFF9800),
                  formKey: formKey,
                  onSave: () {
                    if (formKey.currentState!.validate()) {
                      cubit.addOrUpdateFamilyHistory(
                        FamilyHistoryModel(
                          familyHistoryID: itemToEdit?.familyHistoryID,
                          historyID: historyId,
                          condition: conditionController.text,
                          relative: relativeController.text,
                          onsetAge: int.tryParse(ageController.text),
                          notes: notesController.text,
                          isVerified: isVerified,
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MedicalTextField(
                        controller: conditionController,
                        label: "Condition",
                        isRequired: true,
                      ),
                      MedicalTextField(
                        controller: relativeController,
                        label: "Relative",
                        isRequired: true,
                      ),
                      MedicalTextField(
                        controller: ageController,
                        label: "Onset Age",
                        keyboardType: TextInputType.number,
                      ),
                      MedicalTextField(
                        controller: notesController,
                        label: "Notes",
                        maxLines: 2,
                      ),
                      CheckboxListTile(
                        value: isVerified,
                        activeColor: const Color(0xFFFF9800),
                        title: const Text("Medically Verified"),
                        onChanged: (val) => setState(() => isVerified = val!),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

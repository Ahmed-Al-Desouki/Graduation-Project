import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_dialog_layout.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
import 'package:intl/intl.dart';

class SurgeryDialog {
  static void show(
    BuildContext context,
    int historyId,
    PatientProfileCubit cubit, {
    SurgeryModel? surgeryToEdit,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: surgeryToEdit?.name ?? '',
    );
    final dateController = TextEditingController(
      text: surgeryToEdit?.date?.split('T')[0] ?? '',
    );
    final notesController = TextEditingController(
      text: surgeryToEdit?.notes ?? '',
    );
    final complicationsController = TextEditingController(
      text: surgeryToEdit?.complications ?? '',
    );

    showDialog(
      context: context,
      builder:
          (ctx) => MedicalDialogLayout(
            title: surgeryToEdit == null ? "Add Surgery" : "Edit Surgery",
            themeColor: const Color(0xFF2563EB),
            formKey: formKey,
            onSave: () {
              if (formKey.currentState!.validate()) {
                cubit.addOrUpdateSurgery(
                  SurgeryModel(
                    surgeryID: surgeryToEdit?.surgeryID,
                    historyID: historyId,
                    name: nameController.text,
                    date: "${dateController.text}T00:00:00Z",
                    notes:
                        notesController.text.isEmpty
                            ? null
                            : notesController.text,
                    complications:
                        complicationsController.text.isEmpty
                            ? null
                            : complicationsController.text,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: Column(
              children: [
                MedicalTextField(
                  controller: nameController,
                  label: "Surgery Name",
                  icon: Icons.content_cut,
                  isRequired: true,
                ),
                MedicalTextField(
                  controller: dateController,
                  label: "Date",
                  icon: Icons.calendar_today,
                  readOnly: true,
                  isRequired: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    }
                  },
                ),
                MedicalTextField(
                  controller: notesController,
                  label: "Notes",
                  icon: Icons.note,
                  maxLines: 2,
                ),
                MedicalTextField(
                  controller: complicationsController,
                  label: "Complications",
                  icon: Icons.warning_amber,
                  maxLines: 2,
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
import 'package:intl/intl.dart';

class SurgeryDialog {
  static void show(
    BuildContext context,
    int historyId,
    PatientProfileCubit cubit, {
    SurgeryModel? surgeryToEdit,
  }) {
    final isEdit = surgeryToEdit != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: surgeryToEdit?.name ?? '',
    );
    final dateController = TextEditingController(
      text:
          surgeryToEdit?.date != null ? surgeryToEdit!.date!.split('T')[0] : '',
    );
    final notesController = TextEditingController(
      text: surgeryToEdit?.notes ?? '',
    );
    final complicationsController = TextEditingController(
      text: surgeryToEdit?.complications ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(isEdit ? "Edit Surgery" : "Add Surgery"),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Name Field
                      MedicalTextField(
                        controller: nameController,
                        label: "Surgery Name",
                        icon: Icons.content_cut,
                        isRequired: true,
                      ),

                      // 2. Date Field (with Picker)
                      MedicalTextField(
                        controller: dateController,
                        label: "Date",
                        icon: Icons.calendar_today,
                        isRequired: true,
                        readOnly: true, // عشان يفتح الـ Picker
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

                      // 3. Notes Field
                      MedicalTextField(
                        controller: notesController,
                        label: "Notes (Optional)",
                        icon: Icons.note,
                        maxLines: 2,
                      ),

                      // 4. Complications Field
                      MedicalTextField(
                        controller: complicationsController,
                        label: "Complications (Optional)",
                        icon: Icons.warning_amber,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
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
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

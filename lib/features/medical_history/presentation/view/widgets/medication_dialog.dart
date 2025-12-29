// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'package:intl/intl.dart';

// class MedicationDialog {
//   static void show(
//     BuildContext context,
//     int historyId, {
//     MedicationModel? medToEdit,
//   }) {
//     final formKey = GlobalKey<FormState>();
//     final nameController = TextEditingController(
//       text: medToEdit?.medicationName ?? '',
//     );
//     final dosageController = TextEditingController(
//       text: medToEdit?.dosage ?? '',
//     );
//     final instructionController = TextEditingController(
//       text: medToEdit?.doseInstruction ?? '',
//     );
//     final startDateController = TextEditingController(
//       text: medToEdit?.startDate?.split('T')[0] ?? '',
//     );
//     final endDateController = TextEditingController(
//       text: medToEdit?.endDate?.split('T')[0] ?? '',
//     );

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (ctx) => AlertDialog(
//             title: Text(
//               medToEdit == null ? "Add Medication" : "Edit Medication",
//             ),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextFormField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: "Medication Name *",
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (val) => val!.isEmpty ? "Required" : null,
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: dosageController,
//                               decoration: const InputDecoration(
//                                 labelText: "Dosage *",
//                                 hintText: "500mg",
//                                 border: OutlineInputBorder(),
//                               ),
//                               validator:
//                                   (val) => val!.isEmpty ? "Required" : null,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: TextFormField(
//                               controller: instructionController,
//                               decoration: const InputDecoration(
//                                 labelText: "Instruction *",
//                                 hintText: "Daily",
//                                 border: OutlineInputBorder(),
//                               ),
//                               validator:
//                                   (val) => val!.isEmpty ? "Required" : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: startDateController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 labelText: "Start Date",
//                                 border: OutlineInputBorder(),
//                                 suffixIcon: Icon(Icons.calendar_today),
//                               ),
//                               onTap:
//                                   () => _pickDate(context, startDateController),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: TextFormField(
//                               controller: endDateController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 labelText: "End Date",
//                                 border: OutlineInputBorder(),
//                                 suffixIcon: Icon(Icons.calendar_today),
//                               ),
//                               onTap:
//                                   () => _pickDate(context, endDateController),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF9C27B0),
//                 ),
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     context.read<PatientProfileCubit>().addOrUpdateMedication(
//                       MedicationModel(
//                         currentMedicationID:
//                             medToEdit
//                                 ?.currentMedicationID, // ✅ الـ ID عشان التعديل
//                         historyID: historyId,
//                         medicationName: nameController.text,
//                         dosage: dosageController.text,
//                         doseInstruction: instructionController.text,
//                         startDate:
//                             startDateController.text.isNotEmpty
//                                 ? "${startDateController.text}T00:00:00Z"
//                                 : null,
//                         endDate:
//                             endDateController.text.isNotEmpty
//                                 ? "${endDateController.text}T00:00:00Z"
//                                 : null,
//                         notes: medToEdit?.notes,
//                         isSelfMedication:
//                             true, // دايماً true لأن المريض هو اللي بيضيف
//                       ),
//                     );
//                     Navigator.pop(ctx);
//                   }
//                 },
//                 child: const Text(
//                   "Save",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   static Future<void> _pickDate(
//     BuildContext context,
//     TextEditingController controller,
//   ) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       controller.text = DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }
// }

// // دالة الحذف المشتركة
// void confirmDeleteMedication(BuildContext context, int medId) {
//   showDialog(
//     context: context,
//     builder:
//         (ctx) => AlertDialog(
//           title: const Text("Delete Medication"),
//           content: const Text(
//             "Are you sure you want to delete this medication?",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: () {
//                 // ✅ استدعاء دالة الحذف الحقيقية
//                 context.read<PatientProfileCubit>().deleteSelfMedication(medId);
//                 Navigator.pop(ctx);
//               },
//               child: const Text(
//                 "Delete",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
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

    // Date controllers setup
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
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              medToEdit == null ? "Add Medication" : "Edit Medication",
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MedicalTextField(
                        controller: nameController,
                        label: "Medication Name",
                        isRequired: true,
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
                  backgroundColor: const Color(0xFF9C27B0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    cubit.addOrUpdateMedication(
                      MedicationModel(
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

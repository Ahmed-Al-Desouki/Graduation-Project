// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';

// class FamilyHistoryDialog {
//   static void show(
//     BuildContext context,
//     int historyId, {
//     FamilyHistoryModel? itemToEdit,
//   }) {
//     final formKey = GlobalKey<FormState>();

//     // Initial Values
//     final conditionController = TextEditingController(
//       text: itemToEdit?.condition ?? '',
//     );
//     final relativeController = TextEditingController(
//       text: itemToEdit?.relative ?? '',
//     );
//     final ageController = TextEditingController(
//       text: itemToEdit?.onsetAge?.toString() ?? '',
//     );
//     final notesController = TextEditingController(
//       text: itemToEdit?.notes ?? '',
//     );
//     bool isVerified = itemToEdit?.isVerified ?? false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (ctx) => AlertDialog(
//             title: Text(
//               itemToEdit == null ? "Add Family History" : "Edit Family History",
//             ),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: StatefulBuilder(
//                     builder: (context, setState) {
//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           TextFormField(
//                             controller: conditionController,
//                             decoration: const InputDecoration(
//                               labelText: "Condition (e.g. Diabetes) *",
//                               border: OutlineInputBorder(),
//                             ),
//                             validator:
//                                 (val) => val!.isEmpty ? "Required" : null,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: relativeController,
//                             decoration: const InputDecoration(
//                               labelText: "Relative (e.g. Father) *",
//                               border: OutlineInputBorder(),
//                             ),
//                             validator:
//                                 (val) => val!.isEmpty ? "Required" : null,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: ageController,
//                             decoration: const InputDecoration(
//                               labelText: "Onset Age (Optional)",
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: TextInputType.number,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: notesController,
//                             maxLines: 2,
//                             decoration: const InputDecoration(
//                               labelText: "Notes (Optional)",
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: isVerified,
//                                 activeColor: const Color(0xFFFF9800),
//                                 onChanged:
//                                     (val) => setState(() => isVerified = val!),
//                               ),
//                               const Text("Medically Verified"),
//                             ],
//                           ),
//                         ],
//                       );
//                     },
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
//                   backgroundColor: const Color(0xFFFF9800),
//                 ),
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     // إرسال للكيوبت
//                     context
//                         .read<PatientProfileCubit>()
//                         .addOrUpdateFamilyHistory(
//                           FamilyHistoryModel(
//                             familyHistoryID:
//                                 itemToEdit
//                                     ?.familyHistoryID, // ✅ مهم جداً للـ Edit
//                             historyID: historyId,
//                             condition: conditionController.text,
//                             relative: relativeController.text,
//                             onsetAge: int.tryParse(ageController.text),
//                             notes: notesController.text,
//                             isVerified: isVerified,
//                           ),
//                         );
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
// }

// // دالة حذف مشتركة
// void confirmDeleteFamilyHistory(
//   BuildContext context,
//   int familyId,
//   int historyId,
// ) {
//   showDialog(
//     context: context,
//     builder:
//         (ctx) => AlertDialog(
//           title: const Text("Delete Record"),
//           content: const Text("Are you sure you want to delete this record?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: () {
//                 context.read<PatientProfileCubit>().deleteFamilyHistory(
//                   familyId,
//                   historyId,
//                 );
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
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
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

    // State variable for checkbox needs StatefulBuilder inside Dialog
    bool isVerified = itemToEdit?.isVerified ?? false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(itemToEdit == null ? "Add Record" : "Edit Record"),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MedicalTextField(
                            controller: conditionController,
                            label: "Condition (e.g. Diabetes)",
                            isRequired: true,
                          ),
                          MedicalTextField(
                            controller: relativeController,
                            label: "Relative (e.g. Father)",
                            isRequired: true,
                          ),
                          MedicalTextField(
                            controller: ageController,
                            label: "Onset Age (Optional)",
                            keyboardType: TextInputType.number,
                          ),
                          MedicalTextField(
                            controller: notesController,
                            label: "Notes",
                            maxLines: 2,
                          ),

                          // Checkbox (Custom UI component)
                          CheckboxListTile(
                            value: isVerified,
                            activeColor: const Color(0xFFFF9800),
                            title: const Text("Medically Verified"),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged:
                                (val) => setState(() => isVerified = val!),
                          ),
                        ],
                      );
                    },
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
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
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

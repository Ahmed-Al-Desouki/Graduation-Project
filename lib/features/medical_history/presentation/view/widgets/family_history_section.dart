// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:graduation_project/core/utils/app_router.dart';
// // import 'package:graduation_project/core/utils/functions/confirmDelete.dart';
// // import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// // import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// // import 'dotted_add_button.dart';

// // class FamilyHistorySection extends StatelessWidget {
// //   final List<FamilyHistoryModel> familyHistory;
// //   final int historyId;

// //   const FamilyHistorySection({
// //     super.key,
// //     required this.familyHistory,
// //     required this.historyId,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     // عرض أول 3 فقط
// //     final displayList = familyHistory.take(3).toList();

// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFFFF3E0), // Light Orange
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: const Icon(
// //                       Icons.family_restroom,
// //                       color: Color(0xFFFF9800),
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     "Family History",
// //                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //                   ),
// //                 ],
// //               ),

// //               // View All Button
// //               if (familyHistory.length > 3)
// //                 TextButton(
// //                   onPressed: () {
// //                     context.push(
// //                       AppRouter.kAllFamilyHistory,
// //                       extra: {
// //                         'familyHistory': familyHistory,
// //                         'historyId': historyId,
// //                         'cubit': context.read<PatientProfileCubit>(),
// //                       },
// //                     );
// //                   },
// //                   child: const Text(
// //                     "View All",
// //                     style: TextStyle(
// //                       color: Color(0xFF2563EB),
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 20),

// //           // List
// //           if (familyHistory.isEmpty)
// //             Center(
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 10),
// //                 child: Text(
// //                   "No family history recorded.",
// //                   style: TextStyle(color: Colors.grey.shade400),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...displayList.map((item) => _buildFamilyCard(context, item)),

// //           const SizedBox(height: 20),

// //           // Add Button
// //           DottedAddButton(onTap: () => _showFamilyDialog(context, null)),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFamilyCard(BuildContext context, FamilyHistoryModel item) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.grey.shade50,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Icon(Icons.diversity_1, color: Colors.grey, size: 24),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Text(
// //                       item.condition,
// //                       style: const TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 15,
// //                       ),
// //                     ),
// //                     if (item.isVerified) ...[
// //                       const SizedBox(width: 6),
// //                       const Icon(
// //                         Icons.verified,
// //                         size: 14,
// //                         color: Colors.blue,
// //                       ), // علامة التوثيق
// //                     ],
// //                   ],
// //                 ),
// //                 Text(
// //                   "${item.relative} ${item.onsetAge != null ? '• Onset Age: ${item.onsetAge}' : ''}",
// //                   style: const TextStyle(fontSize: 13, color: Colors.grey),
// //                 ),
// //                 if (item.notes != null && item.notes!.isNotEmpty)
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 4),
// //                     child: Text(
// //                       "Note: ${item.notes}",
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.amber.shade900,
// //                         fontStyle: FontStyle.italic,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //           // Edit
// //           InkWell(
// //             onTap: () => _showFamilyDialog(context, item),
// //             child: const Padding(
// //               padding: EdgeInsets.all(4),
// //               child: Icon(Icons.edit, size: 18, color: Colors.blue),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           // Delete (Mock for now as per your request for UI)
// //           InkWell(
// //             onTap: () {
// //               if (item.familyHistoryID != null) {
// //                 confirmDelete(context, () {
// //                   context.read<PatientProfileCubit>().deleteFamilyHistory(
// //                     item.familyHistoryID!,
// //                     historyId,
// //                   );
// //                 });
// //               }
// //             },
// //             child: const Padding(
// //               padding: EdgeInsets.all(4),
// //               child: Icon(Icons.delete_outline, size: 18, color: Colors.red),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showFamilyDialog(BuildContext context, FamilyHistoryModel? itemToEdit) {
// //     final formKey = GlobalKey<FormState>();
// //     final conditionController = TextEditingController(
// //       text: itemToEdit?.condition ?? '',
// //     );
// //     final relativeController = TextEditingController(
// //       text: itemToEdit?.relative ?? '',
// //     );
// //     final ageController = TextEditingController(
// //       text: itemToEdit?.onsetAge?.toString() ?? '',
// //     );
// //     final notesController = TextEditingController(
// //       text: itemToEdit?.notes ?? '',
// //     );
// //     bool isVerified = itemToEdit?.isVerified ?? false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder:
// //           (ctx) => AlertDialog(
// //             title: Text(
// //               itemToEdit == null ? "Add Family History" : "Edit Family History",
// //             ),
// //             content: SizedBox(
// //               width: double.maxFinite,
// //               child: Form(
// //                 key: formKey,
// //                 child: SingleChildScrollView(
// //                   child: StatefulBuilder(
// //                     // ✅ مهم عشان الـ Checkbox يشتغل جوه الـ Dialog
// //                     builder: (context, setState) {
// //                       return Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           TextFormField(
// //                             controller: conditionController,
// //                             decoration: const InputDecoration(
// //                               labelText: "Condition (e.g. Diabetes) *",
// //                               border: OutlineInputBorder(),
// //                             ),
// //                             validator:
// //                                 (val) => val!.isEmpty ? "Required" : null,
// //                           ),
// //                           const SizedBox(height: 12),
// //                           TextFormField(
// //                             controller: relativeController,
// //                             decoration: const InputDecoration(
// //                               labelText: "Relative (e.g. Father) *",
// //                               border: OutlineInputBorder(),
// //                             ),
// //                             validator:
// //                                 (val) => val!.isEmpty ? "Required" : null,
// //                           ),
// //                           const SizedBox(height: 12),
// //                           TextFormField(
// //                             controller: ageController,
// //                             decoration: const InputDecoration(
// //                               labelText: "Onset Age (Optional)",
// //                               border: OutlineInputBorder(),
// //                             ),
// //                             keyboardType: TextInputType.number,
// //                           ),
// //                           const SizedBox(height: 12),
// //                           TextFormField(
// //                             controller: notesController,
// //                             maxLines: 2,
// //                             decoration: const InputDecoration(
// //                               labelText: "Notes (Optional)",
// //                               border: OutlineInputBorder(),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),

// //                           // ✅ Checkbox for IsVerified
// //                           Row(
// //                             children: [
// //                               Checkbox(
// //                                 value: isVerified,
// //                                 activeColor: const Color(0xFFFF9800),
// //                                 onChanged: (val) {
// //                                   setState(() => isVerified = val!);
// //                                 },
// //                               ),
// //                               const Text("Medically Verified"),
// //                             ],
// //                           ),
// //                         ],
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(ctx),
// //                 child: const Text("Cancel"),
// //               ),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFFFF9800),
// //                 ),
// //                 onPressed: () {
// //                   if (formKey.currentState!.validate()) {
// //                     context
// //                         .read<PatientProfileCubit>()
// //                         .addOrUpdateFamilyHistory(
// //                           FamilyHistoryModel(
// //                             familyHistoryID:
// //                                 itemToEdit?.familyHistoryID, // مهم للـ Update
// //                             historyID: historyId,
// //                             condition: conditionController.text,
// //                             relative: relativeController.text,
// //                             onsetAge: int.tryParse(ageController.text),
// //                             notes: notesController.text,
// //                             isVerified: isVerified, // القيمة من الـ Checkbox
// //                           ),
// //                         );
// //                     Navigator.pop(ctx);
// //                   }
// //                 },
// //                 child: const Text(
// //                   "Save",
// //                   style: TextStyle(color: Colors.white),
// //                 ),
// //               ),
// //             ],
// //           ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'dotted_add_button.dart';
// import 'family_history_card.dart'; // ✅
// import 'family_history_dialog.dart'; // ✅

// class FamilyHistorySection extends StatelessWidget {
//   final List<FamilyHistoryModel> familyHistory;
//   final int historyId;

//   const FamilyHistorySection({
//     super.key,
//     required this.familyHistory,
//     required this.historyId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final displayList = familyHistory.take(3).toList();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF3E0),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.family_restroom,
//                       color: Color(0xFFFF9800),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     "Family History",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//               if (familyHistory.length > 3)
//                 TextButton(
//                   onPressed: () {
//                     context.push(
//                       AppRouter.kAllFamilyHistory,
//                       extra: {
//                         'familyHistory': familyHistory,
//                         'historyId': historyId,
//                         'cubit': context.read<PatientProfileCubit>(),
//                       },
//                     );
//                   },
//                   child: const Text(
//                     "View All",
//                     style: TextStyle(
//                       color: Color(0xFF2563EB),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // List
//           if (familyHistory.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: Text(
//                   "No family history recorded.",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             ...displayList.map(
//               (item) => FamilyHistoryCard(
//                 item: item,
//                 onEdit:
//                     () => FamilyHistoryDialog.show(
//                       context,
//                       historyId,
//                       itemToEdit: item,
//                     ),
//                 onDelete:
//                     () => confirmDeleteFamilyHistory(
//                       context,
//                       item.familyHistoryID!,
//                       historyId,
//                     ),
//               ),
//             ),

//           const SizedBox(height: 20),

//           // Add Button
//           DottedAddButton(
//             onTap: () => FamilyHistoryDialog.show(context, historyId),
//             text: "Add New Family History",
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

class FamilyHistorySection extends StatelessWidget {
  final List<FamilyHistoryModel> familyHistory;
  final int historyId;

  const FamilyHistorySection({
    super.key,
    required this.familyHistory,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Family History",
      icon: Icons.family_restroom,
      themeColor: const Color(0xFFFF9800),
      iconBgColor: const Color(0xFFFFF3E0),
      emptyMessage: "No family history recorded.",

      onAddTap:
          () => FamilyHistoryDialog.show(
            context,
            historyId,
            context.read<PatientProfileCubit>(),
          ),

      onViewAllTap: () {
        context.push(
          AppRouter.kAllFamilyHistory,
          extra: {
            'familyHistory': familyHistory,
            'historyId': historyId,
            'cubit': context.read<PatientProfileCubit>(),
          },
        );
      },

      children:
          familyHistory.take(3).map((item) {
            return FamilyHistoryCard(
              item: item,
              onEdit:
                  () => FamilyHistoryDialog.show(
                    context,
                    historyId,
                    context.read<PatientProfileCubit>(),
                    itemToEdit: item,
                  ),
              onDelete:
                  () => showDeleteConfirmation(
                    context: context,
                    title: "Delete Record",
                    message:
                        "Are you sure you want to delete '${item.condition}'?",
                    onConfirm: () {
                      context.read<PatientProfileCubit>().deleteFamilyHistory(
                        item.familyHistoryID!,
                        historyId,
                      );
                    },
                  ),
            );
          }).toList(),
    );
  }
}

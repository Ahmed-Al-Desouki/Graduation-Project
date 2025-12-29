// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:graduation_project/core/utils/app_router.dart';
// // import 'package:graduation_project/core/utils/functions/confirmDelete.dart';
// // import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// // import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// // import 'package:intl/intl.dart';
// // import 'dotted_add_button.dart';

// // class MedicationsSection extends StatelessWidget {
// //   final List<MedicationModel> medications;
// //   final int historyId;

// //   const MedicationsSection({
// //     super.key,
// //     required this.medications,
// //     required this.historyId,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     // عرض أول 3 عناصر فقط
// //     final displayList = medications.take(3).toList();

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
// //           // --- Header ---
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFF3E5F5),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: const Icon(
// //                       Icons.medication,
// //                       color: Color(0xFF9C27B0),
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     "Current Medications",
// //                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //                   ),
// //                 ],
// //               ),

// //               // زرار View All
// //               if (medications.length > 3)
// //                 TextButton(
// //                   onPressed: () {
// //                     context.push(
// //                       AppRouter.kAllMedications,
// //                       extra: {
// //                         'medications': medications,
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

// //           // --- List Items ---
// //           if (medications.isEmpty)
// //             Center(
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 10),
// //                 child: Text(
// //                   "No medications added.",
// //                   style: TextStyle(color: Colors.grey.shade400),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...displayList.map((item) => _buildMedCard(context, item)),

// //           const SizedBox(height: 20),

// //           // --- Add Button ---
// //           DottedAddButton(onTap: () => _showMedicationDialog(context, null)),
// //         ],
// //       ),
// //     );
// //   }

// //   // دالة بناء الكارت
// //   Widget _buildMedCard(BuildContext context, MedicationModel item) {
// //     // تجهيز نص التاريخ
// //     String dateText = "";
// //     if (item.startDate != null) {
// //       dateText += "Start: ${item.startDate!.split('T')[0]}";
// //     }
// //     if (item.endDate != null) {
// //       if (dateText.isNotEmpty) dateText += "  |  ";
// //       dateText += "End: ${item.endDate!.split('T')[0]}";
// //     }

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
// //           const Icon(Icons.medication_outlined, color: Colors.grey, size: 24),
// //           const SizedBox(width: 12),

// //           // تفاصيل الدواء
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   item.medicationName,
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 15,
// //                   ),
// //                 ),
// //                 if (item.dosage.isNotEmpty || item.doseInstruction.isNotEmpty)
// //                   Text(
// //                     "${item.dosage} • ${item.doseInstruction}",
// //                     style: const TextStyle(fontSize: 13, color: Colors.grey),
// //                   ),

// //                 // التاريخ
// //                 if (dateText.isNotEmpty)
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 4),
// //                     child: Text(
// //                       dateText,
// //                       style: TextStyle(
// //                         fontSize: 11,
// //                         color: Colors.blueGrey.shade600,
// //                       ),
// //                     ),
// //                   ),

// //                 // الملاحظات (للدكتور)
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

// //                 // مصدر الدواء
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   item.isSelfMedication
// //                       ? "Added by You"
// //                       : "Prescribed by Doctor",
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     color: item.isSelfMedication ? Colors.blue : Colors.red,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // ✅ أزرار التحكم (تظهر فقط لو المريض هو اللي ضاف الدوا)
// //           if (item.isSelfMedication) ...[
// //             // Edit
// //             InkWell(
// //               onTap: () => _showMedicationDialog(context, item),
// //               child: const Padding(
// //                 padding: EdgeInsets.all(4),
// //                 child: Icon(Icons.edit, size: 18, color: Colors.blue),
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             // Delete
// //             InkWell(
// //               onTap: () {
// //                 if (item.currentMedicationID != null) {
// //                   confirmDelete(context, () {
// //                     // هنا مش محتاجين historyId حسب الدوكيمنتشن
// //                     context.read<PatientProfileCubit>().deleteSelfMedication(
// //                       item.currentMedicationID!,
// //                     );
// //                   });
// //                 }
// //               },
// //               child: const Padding(
// //                 padding: EdgeInsets.all(4),
// //                 child: Icon(Icons.delete_outline, size: 18, color: Colors.red),
// //               ),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }

// //   // دالة الحذف
// //   // void _confirmDelete(BuildContext context, MedicationModel item) {
// //   //   showDialog(
// //   //     context: context,
// //   //     builder:
// //   //         (ctx) => AlertDialog(
// //   //           title: const Text("Delete Medication"),
// //   //           content: Text(
// //   //             "Are you sure you want to delete '${item.medicationName}'?",
// //   //           ),
// //   //           actions: [
// //   //             TextButton(
// //   //               onPressed: () => Navigator.pop(ctx),
// //   //               child: const Text("Cancel"),
// //   //             ),
// //   //             ElevatedButton(
// //   //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //   //               onPressed: () {
// //   //                 // هنا تنادي دالة الحذف في الكيوبت
// //   //                 // context.read<PatientProfileCubit>().deleteMedication(item.currentMedicationID!);
// //   //                 Navigator.pop(ctx);
// //   //                 ScaffoldMessenger.of(context).showSnackBar(
// //   //                   const SnackBar(
// //   //                     content: Text("Delete feature implementation pending"),
// //   //                   ),
// //   //                 );
// //   //               },
// //   //               child: const Text(
// //   //                 "Delete",
// //   //                 style: TextStyle(color: Colors.white),
// //   //               ),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //   );
// //   // }

// //   // دالة الإضافة/التعديل
// //   void _showMedicationDialog(BuildContext context, MedicationModel? medToEdit) {
// //     final formKey = GlobalKey<FormState>();
// //     final nameController = TextEditingController(
// //       text: medToEdit?.medicationName ?? '',
// //     );
// //     final dosageController = TextEditingController(
// //       text: medToEdit?.dosage ?? '',
// //     );
// //     final instructionController = TextEditingController(
// //       text: medToEdit?.doseInstruction ?? '',
// //     );
// //     final startDateController = TextEditingController(
// //       text: medToEdit?.startDate?.split('T')[0] ?? '',
// //     );
// //     final endDateController = TextEditingController(
// //       text: medToEdit?.endDate?.split('T')[0] ?? '',
// //     );

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder:
// //           (ctx) => AlertDialog(
// //             title: Text(
// //               medToEdit == null ? "Add Medication" : "Edit Medication",
// //             ),
// //             content: SizedBox(
// //               width: double.maxFinite,
// //               child: Form(
// //                 key: formKey,
// //                 child: SingleChildScrollView(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       TextFormField(
// //                         controller: nameController,
// //                         decoration: const InputDecoration(
// //                           labelText: "Medication Name *",
// //                           border: OutlineInputBorder(),
// //                         ),
// //                         validator: (val) => val!.isEmpty ? "Required" : null,
// //                       ),
// //                       const SizedBox(height: 12),
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: dosageController,
// //                               decoration: const InputDecoration(
// //                                 labelText: "Dosage *",
// //                                 hintText: "500mg",
// //                                 border: OutlineInputBorder(),
// //                               ),
// //                               validator:
// //                                   (val) => val!.isEmpty ? "Required" : null,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: instructionController,
// //                               decoration: const InputDecoration(
// //                                 labelText: "Instruction *",
// //                                 hintText: "Daily",
// //                                 border: OutlineInputBorder(),
// //                               ),
// //                               validator:
// //                                   (val) => val!.isEmpty ? "Required" : null,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 12),
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: startDateController,
// //                               readOnly: true,
// //                               decoration: const InputDecoration(
// //                                 labelText: "Start Date",
// //                                 border: OutlineInputBorder(),
// //                                 suffixIcon: Icon(
// //                                   Icons.calendar_today,
// //                                   size: 16,
// //                                 ),
// //                               ),
// //                               onTap:
// //                                   () => _pickDate(context, startDateController),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: endDateController,
// //                               readOnly: true,
// //                               decoration: const InputDecoration(
// //                                 labelText: "End Date",
// //                                 border: OutlineInputBorder(),
// //                                 suffixIcon: Icon(
// //                                   Icons.calendar_today,
// //                                   size: 16,
// //                                 ),
// //                               ),
// //                               onTap:
// //                                   () => _pickDate(context, endDateController),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
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
// //                   backgroundColor: const Color(0xFF9C27B0),
// //                 ),
// //                 onPressed: () {
// //                   if (formKey.currentState!.validate()) {
// //                     context.read<PatientProfileCubit>().addOrUpdateMedication(
// //                       MedicationModel(
// //                         currentMedicationID: medToEdit?.currentMedicationID,
// //                         historyID: historyId,
// //                         medicationName: nameController.text,
// //                         dosage: dosageController.text,
// //                         doseInstruction: instructionController.text,
// //                         startDate:
// //                             startDateController.text.isNotEmpty
// //                                 ? "${startDateController.text}T00:00:00Z"
// //                                 : null,
// //                         endDate:
// //                             endDateController.text.isNotEmpty
// //                                 ? "${endDateController.text}T00:00:00Z"
// //                                 : null,
// //                         notes:
// //                             medToEdit
// //                                 ?.notes, // Preserve doctor notes if editing
// //                       ),
// //                     );
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

// //   Future<void> _pickDate(
// //     BuildContext context,
// //     TextEditingController controller,
// //   ) async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null) {
// //       controller.text = DateFormat('yyyy-MM-dd').format(picked);
// //     }
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'dotted_add_button.dart';
// import 'medication_card.dart'; // ✅
// import 'medication_dialog.dart'; // ✅

// class MedicationsSection extends StatelessWidget {
//   final List<MedicationModel> medications;
//   final int historyId;

//   const MedicationsSection({
//     super.key,
//     required this.medications,
//     required this.historyId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final displayList = medications.take(3).toList();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
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
//                       color: const Color(0xFFF3E5F5),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.medication,
//                       color: Color(0xFF9C27B0),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     "Current Medications",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//               if (medications.length > 3)
//                 TextButton(
//                   onPressed: () {
//                     context.push(
//                       AppRouter.kAllMedications,
//                       extra: {
//                         'medications': medications,
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
//           if (medications.isEmpty)
//             const Center(child: Text("No medications added."))
//           else
//             ...displayList.map(
//               (item) => MedicationCard(
//                 item: item,
//                 onEdit:
//                     () => MedicationDialog.show(
//                       context,
//                       historyId,
//                       medToEdit: item,
//                     ),
//                 onDelete:
//                     () => confirmDeleteMedication(
//                       context,
//                       item.currentMedicationID!,
//                     ),
//               ),
//             ),

//           const SizedBox(height: 20),

//           // Add
//           DottedAddButton(
//             onTap: () => MedicationDialog.show(context, historyId),
//             text: "Add New Medication",
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
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_dialog.dart';

class MedicationsSection extends StatelessWidget {
  final List<MedicationModel> medications;
  final int historyId;

  const MedicationsSection({
    super.key,
    required this.medications,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Current Medications",
      icon: Icons.medication,
      themeColor: const Color(0xFF9C27B0),
      iconBgColor: const Color(0xFFF3E5F5),
      emptyMessage: "No medications added.",

      onAddTap:
          () => MedicationDialog.show(
            context,
            historyId,
            context.read<PatientProfileCubit>(),
          ),

      onViewAllTap: () {
        context.push(
          AppRouter.kAllMedications,
          extra: {
            'medications': medications,
            'historyId': historyId,
            'cubit': context.read<PatientProfileCubit>(),
          },
        );
      },

      children:
          medications.take(3).map((item) {
            return MedicationCard(
              item: item,
              onEdit:
                  () => MedicationDialog.show(
                    context,
                    historyId,
                    context.read<PatientProfileCubit>(),
                    medToEdit: item,
                  ),
              onDelete:
                  () => showDeleteConfirmation(
                    context: context,
                    title: "Delete Medication",
                    message:
                        "Are you sure you want to delete '${item.medicationName}'?",
                    onConfirm: () {
                      context.read<PatientProfileCubit>().deleteSelfMedication(
                        item.currentMedicationID!,
                      );
                    },
                  ),
            );
          }).toList(),
    );
  }
}

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
// // import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';

// // class SocialHistorySection extends StatelessWidget {
// //   final SocialHistoryModel? socialHistory;
// //   final int historyId;

// //   const SocialHistorySection({
// //     super.key,
// //     required this.socialHistory,
// //     required this.historyId,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
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
// //                       color: const Color(0xFFF1F8E9),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: const Icon(
// //                       Icons.people_alt,
// //                       color: Color(0xFF689F38),
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     "Social History",
// //                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //                   ),
// //                 ],
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
// //                 onPressed: () => _showEditDialog(context),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),

// //           if (socialHistory == null)
// //             const Text(
// //               "No social history recorded.",
// //               style: TextStyle(color: Colors.grey),
// //             )
// //           else
// //             Column(
// //               children: [
// //                 _buildRow("Smoking", socialHistory!.smokingStatus),
// //                 if (socialHistory!.smokingDetails != null &&
// //                     socialHistory!.smokingDetails!.isNotEmpty)
// //                   _buildSubRow(socialHistory!.smokingDetails!),

// //                 const Divider(height: 16),

// //                 _buildRow("Alcohol", socialHistory!.alcoholUse),
// //                 _buildRow("Drug Use", socialHistory!.drugUse ?? "None"),

// //                 const Divider(height: 16),

// //                 _buildRow("Occupation", socialHistory!.occupation ?? "N/A"),
// //                 _buildRow("Exercise", socialHistory!.exercise ?? "N/A"),

// //                 if (socialHistory!.notes != null &&
// //                     socialHistory!.notes!.isNotEmpty) ...[
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey.shade50,
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: Colors.grey.shade200),
// //                     ),
// //                     child: Text(
// //                       "📝 ${socialHistory!.notes}",
// //                       style: const TextStyle(
// //                         fontSize: 12,
// //                         fontStyle: FontStyle.italic,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 6.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
// //           ),
// //           Text(
// //             value,
// //             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSubRow(String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8.0, left: 12),
// //       child: Row(
// //         children: [
// //           const Icon(
// //             Icons.subdirectory_arrow_right,
// //             size: 14,
// //             color: Colors.grey,
// //           ),
// //           const SizedBox(width: 4),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showEditDialog(BuildContext context) {
// //     final smokingController = TextEditingController(
// //       text: socialHistory?.smokingStatus ?? "Never",
// //     );
// //     final smokingDetailsController = TextEditingController(
// //       text: socialHistory?.smokingDetails ?? "",
// //     );
// //     final alcoholController = TextEditingController(
// //       text: socialHistory?.alcoholUse ?? "Never",
// //     );
// //     final drugController = TextEditingController(
// //       text: socialHistory?.drugUse ?? "None",
// //     );
// //     final occupationController = TextEditingController(
// //       text: socialHistory?.occupation ?? "",
// //     );
// //     final exerciseController = TextEditingController(
// //       text: socialHistory?.exercise ?? "",
// //     );
// //     final notesController = TextEditingController(
// //       text: socialHistory?.notes ?? "",
// //     );

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder:
// //           (ctx) => AlertDialog(
// //             title: const Text("Update Social History"),
// //             content: SizedBox(
// //               width: double.maxFinite,
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     // 1. Habits
// //                     const Text(
// //                       "Habits",
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blueGrey,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),

// //                     // Smoking Dropdown (Better UX)
// //                     DropdownButtonFormField<String>(
// //                       value:
// //                           [
// //                                 "Never",
// //                                 "Former",
// //                                 "Current",
// //                               ].contains(smokingController.text)
// //                               ? smokingController.text
// //                               : "Never",
// //                       items:
// //                           ["Never", "Former", "Current"]
// //                               .map(
// //                                 (e) =>
// //                                     DropdownMenuItem(value: e, child: Text(e)),
// //                               )
// //                               .toList(),
// //                       onChanged: (val) => smokingController.text = val!,
// //                       decoration: const InputDecoration(
// //                         labelText: "Smoking Status",
// //                         border: OutlineInputBorder(),
// //                         contentPadding: EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 12,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextField(
// //                       controller: smokingDetailsController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Smoking Details (Optional)",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 10),
// //                     // Alcohol Dropdown
// //                     DropdownButtonFormField<String>(
// //                       value:
// //                           [
// //                                 "Never",
// //                                 "Occasional",
// //                                 "Regular",
// //                               ].contains(alcoholController.text)
// //                               ? alcoholController.text
// //                               : "Never",
// //                       items:
// //                           ["Never", "Occasional", "Regular"]
// //                               .map(
// //                                 (e) =>
// //                                     DropdownMenuItem(value: e, child: Text(e)),
// //                               )
// //                               .toList(),
// //                       onChanged: (val) => alcoholController.text = val!,
// //                       decoration: const InputDecoration(
// //                         labelText: "Alcohol Use",
// //                         border: OutlineInputBorder(),
// //                         contentPadding: EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 12,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextField(
// //                       controller: drugController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Drug Use (e.g. None)",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),

// //                     const Divider(height: 24),

// //                     // 2. Lifestyle
// //                     const Text(
// //                       "Lifestyle",
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blueGrey,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextField(
// //                       controller: occupationController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Occupation",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextField(
// //                       controller: exerciseController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Exercise (e.g. 3x/week)",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 10),
// //                     TextField(
// //                       controller: notesController,
// //                       maxLines: 2,
// //                       decoration: const InputDecoration(
// //                         labelText: "Additional Notes",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(ctx),
// //                 child: const Text("Cancel"),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   context.read<PatientProfileCubit>().addOrUpdateSocialHistory(
// //                     SocialHistoryModel(
// //                       socialHistoryID:
// //                           socialHistory
// //                               ?.socialHistoryID, // الحفاظ على الـ ID للتعديل
// //                       historyID: historyId,
// //                       smokingStatus: smokingController.text,
// //                       smokingDetails: smokingDetailsController.text,
// //                       alcoholUse: alcoholController.text,
// //                       drugUse: drugController.text,
// //                       occupation: occupationController.text,
// //                       exercise: exerciseController.text,
// //                       notes: notesController.text,
// //                     ),
// //                   );
// //                   Navigator.pop(ctx);
// //                 },
// //                 child: const Text("Save"),
// //               ),
// //             ],
// //           ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

// class SocialHistorySection extends StatelessWidget {
//   final SocialHistoryModel? socialHistory;
//   final int historyId;

//   const SocialHistorySection({
//     super.key,
//     required this.socialHistory,
//     required this.historyId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MedicalSectionCard(
//       title: "Social History",
//       icon: Icons.people_alt,
//       themeColor: const Color(0xFF689F38),
//       iconBgColor: const Color(0xFFF1F8E9),
//       emptyMessage: "No social history recorded.",

//       // الزرار السفلي هيفتح الدايالوج سواء للإضافة أو التعديل
//       onAddTap: () => _showEditDialog(context),

//       // لو مفيش داتا، الليستة هتكون فاضية فالكارت هيعرض emptyMessage
//       children:
//           socialHistory == null
//               ? []
//               : [
//                 _buildRow("Smoking", socialHistory!.smokingStatus),
//                 if (socialHistory!.smokingDetails?.isNotEmpty == true)
//                   _buildSubRow(socialHistory!.smokingDetails!),
//                 const Divider(height: 24),
//                 _buildRow("Alcohol", socialHistory!.alcoholUse),
//                 _buildRow("Drug Use", socialHistory!.drugUse ?? "None"),
//                 const Divider(height: 24),
//                 _buildRow("Occupation", socialHistory!.occupation ?? "N/A"),
//                 _buildRow("Exercise", socialHistory!.exercise ?? "N/A"),
//                 if (socialHistory!.notes?.isNotEmpty == true) ...[
//                   const SizedBox(height: 12),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey.shade200),
//                     ),
//                     child: Text(
//                       "📝 ${socialHistory!.notes}",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//     );
//   }

//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubRow(String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0, left: 16),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.subdirectory_arrow_right,
//             size: 16,
//             color: Colors.grey,
//           ),
//           const SizedBox(width: 4),
//           Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   void _showEditDialog(BuildContext context) {
//     final smokingController = TextEditingController(
//       text: socialHistory?.smokingStatus ?? "Never",
//     );
//     final smokingDetailsController = TextEditingController(
//       text: socialHistory?.smokingDetails ?? "",
//     );
//     final alcoholController = TextEditingController(
//       text: socialHistory?.alcoholUse ?? "Never",
//     );
//     final drugController = TextEditingController(
//       text: socialHistory?.drugUse ?? "None",
//     );
//     final occupationController = TextEditingController(
//       text: socialHistory?.occupation ?? "",
//     );
//     final exerciseController = TextEditingController(
//       text: socialHistory?.exercise ?? "",
//     );
//     final notesController = TextEditingController(
//       text: socialHistory?.notes ?? "",
//     );

//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: const Text("Update Social History"),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Habits",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     // استخدام الـ MedicalDropdown الجديد
//                     MedicalDropdown<String>(
//                       label: "Smoking Status",
//                       value: smokingController.text,
//                       items: const ["Never", "Former", "Current"],
//                       onChanged: (val) => smokingController.text = val!,
//                       itemLabelBuilder: (item) => item,
//                     ),

//                     MedicalTextField(
//                       controller: smokingDetailsController,
//                       label: "Smoking Details (Optional)",
//                     ),

//                     MedicalDropdown<String>(
//                       label: "Alcohol Use",
//                       value: alcoholController.text,
//                       items: const ["Never", "Occasional", "Regular"],
//                       onChanged: (val) => alcoholController.text = val!,
//                       itemLabelBuilder: (item) => item,
//                     ),

//                     MedicalTextField(
//                       controller: drugController,
//                       label: "Drug Use",
//                       hint: "e.g. None",
//                     ),

//                     const SizedBox(height: 16),
//                     const Text(
//                       "Lifestyle",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     MedicalTextField(
//                       controller: occupationController,
//                       label: "Occupation",
//                     ),
//                     MedicalTextField(
//                       controller: exerciseController,
//                       label: "Exercise",
//                       hint: "e.g. 3x/week",
//                     ),
//                     MedicalTextField(
//                       controller: notesController,
//                       label: "Additional Notes",
//                       maxLines: 2,
//                     ),
//                   ],
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
//                   backgroundColor: const Color(0xFF689F38),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   context.read<PatientProfileCubit>().addOrUpdateSocialHistory(
//                     SocialHistoryModel(
//                       socialHistoryID: socialHistory?.socialHistoryID,
//                       historyID: historyId,
//                       smokingStatus: smokingController.text,
//                       smokingDetails: smokingDetailsController.text,
//                       alcoholUse: alcoholController.text,
//                       drugUse: drugController.text,
//                       occupation: occupationController.text,
//                       exercise: exerciseController.text,
//                       notes: notesController.text,
//                     ),
//                   );
//                   Navigator.pop(ctx);
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

class SocialHistorySection extends StatelessWidget {
  final SocialHistoryModel? socialHistory;
  final int historyId;

  const SocialHistorySection({
    super.key,
    required this.socialHistory,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Social History",
      icon: Icons.people_alt,
      themeColor: const Color(0xFF689F38),
      iconBgColor: const Color(0xFFF1F8E9),
      emptyMessage: "No social history recorded.",

      // ✅ 1. إزالة زرار الإضافة السفلي (onAddTap) نهائياً عن طريق عدم تمريره

      // ✅ 2. إضافة زرار تعديل في الهيدر
      actionWidget: IconButton(
        onPressed: () => _showEditDialog(context),
        icon: Row(
          children: [
            const Icon(Icons.edit, color: Color(0xFF2563EB), size: 20),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        tooltip: "Edit Social History",
        constraints: const BoxConstraints(), // لتقليل المساحة الزائدة
        padding: EdgeInsets.zero,
      ),

      children:
          socialHistory == null
              ? []
              : [
                _buildRow("Smoking", socialHistory!.smokingStatus),
                if (socialHistory!.smokingDetails?.isNotEmpty == true)
                  _buildSubRow(socialHistory!.smokingDetails!),
                const Divider(height: 24),
                _buildRow("Alcohol", socialHistory!.alcoholUse),
                _buildRow("Drug Use", socialHistory!.drugUse ?? "None"),
                const Divider(height: 24),
                _buildRow("Occupation", socialHistory!.occupation ?? "N/A"),
                _buildRow("Exercise", socialHistory!.exercise ?? "N/A"),
                if (socialHistory!.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      "📝 ${socialHistory!.notes}",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16),
      child: Row(
        children: [
          const Icon(
            Icons.subdirectory_arrow_right,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final smokingController = TextEditingController(
      text: socialHistory?.smokingStatus ?? "Never",
    );
    final smokingDetailsController = TextEditingController(
      text: socialHistory?.smokingDetails ?? "",
    );
    final alcoholController = TextEditingController(
      text: socialHistory?.alcoholUse ?? "Never",
    );
    final drugController = TextEditingController(
      text: socialHistory?.drugUse ?? "None",
    );
    final occupationController = TextEditingController(
      text: socialHistory?.occupation ?? "",
    );
    final exerciseController = TextEditingController(
      text: socialHistory?.exercise ?? "",
    );
    final notesController = TextEditingController(
      text: socialHistory?.notes ?? "",
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Update Social History"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Habits",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    MedicalDropdown<String>(
                      label: "Smoking Status",
                      value: smokingController.text,
                      items: const ["Never", "Former", "Current"],
                      onChanged: (val) => smokingController.text = val!,
                      itemLabelBuilder: (item) => item,
                    ),

                    MedicalTextField(
                      controller: smokingDetailsController,
                      label: "Smoking Details (Optional)",
                    ),

                    MedicalDropdown<String>(
                      label: "Alcohol Use",
                      value: alcoholController.text,
                      items: const ["Never", "Occasional", "Regular"],
                      onChanged: (val) => alcoholController.text = val!,
                      itemLabelBuilder: (item) => item,
                    ),

                    MedicalTextField(
                      controller: drugController,
                      label: "Drug Use",
                      hint: "e.g. None",
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Lifestyle",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    MedicalTextField(
                      controller: occupationController,
                      label: "Occupation",
                    ),
                    MedicalTextField(
                      controller: exerciseController,
                      label: "Exercise",
                      hint: "e.g. 3x/week",
                    ),
                    MedicalTextField(
                      controller: notesController,
                      label: "Additional Notes",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689F38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.read<PatientProfileCubit>().addOrUpdateSocialHistory(
                    SocialHistoryModel(
                      socialHistoryID: socialHistory?.socialHistoryID,
                      historyID: historyId,
                      smokingStatus: smokingController.text,
                      smokingDetails: smokingDetailsController.text,
                      alcoholUse: alcoholController.text,
                      drugUse: drugController.text,
                      occupation: occupationController.text,
                      exercise: exerciseController.text,
                      notes: notesController.text,
                    ),
                  );
                  Navigator.pop(ctx);
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

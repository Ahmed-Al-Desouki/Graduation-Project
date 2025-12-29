// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/core/utils/functions/confirmDelete.dart';
// import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';

// class AllFamilyHistoryView extends StatefulWidget {
//   final List<FamilyHistoryModel> allRecords;
//   final int historyId;
//   final PatientProfileCubit cubit;

//   const AllFamilyHistoryView({
//     super.key,
//     required this.allRecords,
//     required this.historyId,
//     required this.cubit,
//   });

//   @override
//   State<AllFamilyHistoryView> createState() => _AllFamilyHistoryViewState();
// }

// class _AllFamilyHistoryViewState extends State<AllFamilyHistoryView> {
//   String _searchQuery = "";
//   late List<FamilyHistoryModel> _filteredList;

//   @override
//   void initState() {
//     super.initState();
//     _filteredList = widget.allRecords;
//   }

//   void _applyFilter(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredList =
//           widget.allRecords.where((item) {
//             return item.condition.toLowerCase().contains(query.toLowerCase()) ||
//                 item.relative.toLowerCase().contains(query.toLowerCase());
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: widget.cubit,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF3F4F6),
//         appBar: AppBar(
//           title: const Text(
//             "Family History",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0.5,
//           leading: const BackButton(color: Colors.black),
//         ),
//         body: Column(
//           children: [
//             // Search Bar
//             Container(
//               color: Colors.white,
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 onChanged: _applyFilter,
//                 decoration: InputDecoration(
//                   hintText: "Search condition or relative...",
//                   prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             // List
//             Expanded(
//               child:
//                   _filteredList.isEmpty
//                       ? const Center(child: Text("No records found."))
//                       : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: _filteredList.length,
//                         itemBuilder: (context, index) {
//                           final item = _filteredList[index];
//                           return _buildFamilyCard(item);
//                         },
//                       ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ تصميم الكارت مع أزرار التعديل والحذف
//   Widget _buildFamilyCard(FamilyHistoryModel item) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.diversity_1, color: Colors.orange),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         item.condition,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       if (item.isVerified) ...[
//                         const SizedBox(width: 6),
//                         const Icon(
//                           Icons.verified,
//                           size: 16,
//                           color: Colors.blue,
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "Relative: ${item.relative} ${item.onsetAge != null ? '(Age: ${item.onsetAge})' : ''}",
//                     style: const TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                   if (item.notes != null && item.notes!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Text(
//                         "Note: ${item.notes}",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.amber.shade900,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // ✅ أزرار التحكم
//             Column(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
//                   onPressed: () => _showEditDialog(context, item),
//                   constraints: const BoxConstraints(),
//                   padding: EdgeInsets.zero,
//                 ),
//                 const SizedBox(height: 12),
//                 IconButton(
//                   icon: const Icon(
//                     Icons.delete_outline,
//                     size: 20,
//                     color: Colors.red,
//                   ),
//                   onPressed: () => _confirmDelete(context, item),
//                   constraints: const BoxConstraints(),
//                   padding: EdgeInsets.zero,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ دالة التعديل (نفس اللي في الـ Section)
//   void _showEditDialog(BuildContext context, FamilyHistoryModel itemToEdit) {
//     final formKey = GlobalKey<FormState>();
//     final conditionController = TextEditingController(
//       text: itemToEdit.condition,
//     );
//     final relativeController = TextEditingController(text: itemToEdit.relative);
//     final ageController = TextEditingController(
//       text: itemToEdit.onsetAge?.toString() ?? '',
//     );
//     final notesController = TextEditingController(text: itemToEdit.notes ?? '');
//     bool isVerified = itemToEdit.isVerified;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (ctx) => AlertDialog(
//             title: const Text("Edit Family History"),
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
//                               labelText: "Condition *",
//                               border: OutlineInputBorder(),
//                             ),
//                             validator:
//                                 (val) => val!.isEmpty ? "Required" : null,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: relativeController,
//                             decoration: const InputDecoration(
//                               labelText: "Relative *",
//                               border: OutlineInputBorder(),
//                             ),
//                             validator:
//                                 (val) => val!.isEmpty ? "Required" : null,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: ageController,
//                             decoration: const InputDecoration(
//                               labelText: "Onset Age",
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: TextInputType.number,
//                           ),
//                           const SizedBox(height: 12),
//                           TextFormField(
//                             controller: notesController,
//                             maxLines: 2,
//                             decoration: const InputDecoration(
//                               labelText: "Notes",
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
//                     widget.cubit.addOrUpdateFamilyHistory(
//                       FamilyHistoryModel(
//                         familyHistoryID:
//                             itemToEdit.familyHistoryID, // ID للتعديل
//                         historyID: widget.historyId,
//                         condition: conditionController.text,
//                         relative: relativeController.text,
//                         onsetAge: int.tryParse(ageController.text),
//                         notes: notesController.text,
//                         isVerified: isVerified,
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

//   // ✅ دالة الحذف
//   void _confirmDelete(BuildContext context, FamilyHistoryModel item) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: const Text("Delete Record"),
//             content: Text("Delete history for '${item.condition}'?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 onPressed: () {
//                   // TODO: Call Delete API here when ready
//                   // widget.cubit.deleteFamilyHistory(item.familyHistoryID!);

//                   if (item.familyHistoryID != null) {
//                     confirmDelete(context, () {
//                       context.read<PatientProfileCubit>().deleteFamilyHistory(
//                         item.familyHistoryID!,
//                         widget.historyId,
//                       );
//                     });
//                   }
//                   Navigator.pop(ctx);
//                 },
//                 child: const Text(
//                   "Delete",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_card.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_dialog.dart';

// class AllFamilyHistoryView extends StatefulWidget {
//   final List<FamilyHistoryModel> allRecords;
//   final int historyId;
//   final PatientProfileCubit cubit;

//   const AllFamilyHistoryView({
//     super.key,
//     required this.allRecords,
//     required this.historyId,
//     required this.cubit,
//   });

//   @override
//   State<AllFamilyHistoryView> createState() => _AllFamilyHistoryViewState();
// }

// class _AllFamilyHistoryViewState extends State<AllFamilyHistoryView> {
//   String _searchQuery = "";
//   late List<FamilyHistoryModel> _currentList; // القائمة الحالية من الكيوبت
//   late List<FamilyHistoryModel> _filteredList; // القائمة بعد البحث

//   @override
//   void initState() {
//     super.initState();
//     _currentList = widget.allRecords;
//     _filteredList = _currentList;
//   }

//   void _applyFilter() {
//     setState(() {
//       _filteredList =
//           _currentList.where((item) {
//             return item.condition.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ||
//                 item.relative.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 );
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ استخدام BlocProvider + BlocConsumer للتحديث الفوري
//     return BlocProvider.value(
//       value: widget.cubit,
//       child: BlocConsumer<PatientProfileCubit, PatientProfileState>(
//         listener: (context, state) {
//           if (state is PatientOperationSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           // ✅ لما البيانات تتحدث في الكيوبت، ناخد القائمة الجديدة
//           if (state is PatientProfileSuccess) {
//             _currentList = state.profile.familyHistory;
//             // إعادة تطبيق الفلتر (لأن القائمة الأصلية اتغيرت)
//             _filteredList =
//                 _currentList.where((item) {
//                   return item.condition.toLowerCase().contains(
//                         _searchQuery.toLowerCase(),
//                       ) ||
//                       item.relative.toLowerCase().contains(
//                         _searchQuery.toLowerCase(),
//                       );
//                 }).toList();
//           }

//           return Scaffold(
//             backgroundColor: const Color(0xFFF3F4F6),
//             appBar: AppBar(
//               title: const Text(
//                 "Family History",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               backgroundColor: Colors.white,
//               elevation: 0.5,
//               leading: const BackButton(color: Colors.black),
//             ),
//             body: Column(
//               children: [
//                 // Search Bar
//                 Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.all(16),
//                   child: TextField(
//                     onChanged: (val) {
//                       _searchQuery = val;
//                       _applyFilter();
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Search condition or relative...",
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // List
//                 Expanded(
//                   child:
//                       _filteredList.isEmpty
//                           ? const Center(child: Text("No records found."))
//                           : ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: _filteredList.length,
//                             itemBuilder: (context, index) {
//                               final item = _filteredList[index];
//                               // ✅ استخدام الكارت المشترك
//                               return FamilyHistoryCard(
//                                 item: item,
//                                 onEdit:
//                                     () => FamilyHistoryDialog.show(
//                                       context,
//                                       widget.historyId,
//                                       itemToEdit: item,
//                                     ),
//                                 onDelete:
//                                     () => confirmDeleteFamilyHistory(
//                                       context,
//                                       item.familyHistoryID!,
//                                       widget.historyId,
//                                     ),
//                               );
//                             },
//                           ),
//                 ),
//               ],
//             ),

//             // زرار إضافة عائم
//             floatingActionButton: FloatingActionButton(
//               onPressed:
//                   () => FamilyHistoryDialog.show(context, widget.historyId),
//               backgroundColor: const Color(0xFFFF9800),
//               child: const Icon(Icons.add, color: Colors.white),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_dialog.dart';

class AllFamilyHistoryView extends StatefulWidget {
  final List<FamilyHistoryModel> allRecords;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllFamilyHistoryView({
    super.key,
    required this.allRecords,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllFamilyHistoryView> createState() => _AllFamilyHistoryViewState();
}

class _AllFamilyHistoryViewState extends State<AllFamilyHistoryView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text(
            "Family History",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: const BackButton(color: Colors.black),
        ),
        body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is PatientOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            // 1. تحديد مصدر البيانات (من الـ State لو ناجح، أو من الـ Widget كبديل)
            List<FamilyHistoryModel> currentList = widget.allRecords;

            if (state is PatientProfileSuccess) {
              currentList = state.profile.familyHistory;
            }

            // 2. تطبيق الفلترة
            final filteredList =
                currentList.where((item) {
                  final query = _searchQuery.toLowerCase();
                  return item.condition.toLowerCase().contains(query) ||
                      item.relative.toLowerCase().contains(query);
                }).toList();

            return Column(
              children: [
                // --- Search Bar ---
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search condition or relative...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),

                // --- List ---
                Expanded(
                  child:
                      filteredList.isEmpty
                          ? const Center(
                            child: Text(
                              "No records found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return FamilyHistoryCard(
                                item: item,
                                onEdit:
                                    () => FamilyHistoryDialog.show(
                                      context,
                                      widget.historyId,
                                      widget.cubit,
                                      itemToEdit: item,
                                    ),
                                onDelete:
                                    () => showDeleteConfirmation(
                                      context: context,
                                      title: "Delete Record",
                                      message:
                                          "Are you sure you want to delete '${item.condition}'?",
                                      onConfirm: () {
                                        context
                                            .read<PatientProfileCubit>()
                                            .deleteFamilyHistory(
                                              item.familyHistoryID!,
                                              widget.historyId,
                                            );
                                      },
                                    ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              () => FamilyHistoryDialog.show(
                context,
                widget.historyId,
                widget.cubit,
              ),
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

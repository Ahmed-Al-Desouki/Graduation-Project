// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// // import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// // import 'package:intl/intl.dart';

// // class AllMedicationsView extends StatefulWidget {
// //   final List<MedicationModel> allMedications;
// //   final int historyId;
// //   final PatientProfileCubit cubit;

// //   const AllMedicationsView({
// //     super.key,
// //     required this.allMedications,
// //     required this.historyId,
// //     required this.cubit,
// //   });

// //   @override
// //   State<AllMedicationsView> createState() => _AllMedicationsViewState();
// // }

// // class _AllMedicationsViewState extends State<AllMedicationsView> {
// //   String _searchQuery = "";
// //   DateTimeRange? _selectedDateRange;
// //   int _filterSourceIndex = 0; // 0: All, 1: Prescribed, 2: Self

// //   late List<MedicationModel> _filteredList;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _filteredList = widget.allMedications;
// //   }

// //   void _applyFilters() {
// //     setState(() {
// //       _filteredList =
// //           widget.allMedications.where((med) {
// //             final matchesName = med.medicationName.toLowerCase().contains(
// //               _searchQuery.toLowerCase(),
// //             );

// //             bool matchesDate = true;
// //             if (_selectedDateRange != null && med.startDate != null) {
// //               final medStart = DateTime.parse(med.startDate!);
// //               matchesDate =
// //                   medStart.isAfter(
// //                     _selectedDateRange!.start.subtract(const Duration(days: 1)),
// //                   ) &&
// //                   medStart.isBefore(
// //                     _selectedDateRange!.end.add(const Duration(days: 1)),
// //                   );
// //             }

// //             bool matchesSource = true;
// //             if (_filterSourceIndex == 1) matchesSource = !med.isSelfMedication;
// //             if (_filterSourceIndex == 2) matchesSource = med.isSelfMedication;

// //             return matchesName && matchesDate && matchesSource;
// //           }).toList();
// //     });
// //   }

// //   Future<void> _pickDateRange() async {
// //     final picked = await showDateRangePicker(
// //       context: context,
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2030),
// //       builder:
// //           (context, child) => Theme(
// //             data: ThemeData.light().copyWith(
// //               colorScheme: const ColorScheme.light(primary: Color(0xFF9C27B0)),
// //             ),
// //             child: child!,
// //           ),
// //     );
// //     if (picked != null) {
// //       _selectedDateRange = picked;
// //       _applyFilters();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider.value(
// //       value: widget.cubit,
// //       child: Scaffold(
// //         backgroundColor: const Color(0xFFF3F4F6),
// //         appBar: AppBar(
// //           title: const Text(
// //             "All Medications",
// //             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
// //           ),
// //           backgroundColor: Colors.white,
// //           elevation: 0.5,
// //           leading: const BackButton(color: Colors.black),
// //         ),
// //         body: Column(
// //           children: [
// //             Container(
// //               color: Colors.white,
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   // Search
// //                   TextField(
// //                     onChanged: (val) {
// //                       _searchQuery = val;
// //                       _applyFilters();
// //                     },
// //                     decoration: InputDecoration(
// //                       hintText: "Search medications...",
// //                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
// //                       filled: true,
// //                       fillColor: Colors.grey.shade100,
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   // Filters
// //                   SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: Row(
// //                       children: [
// //                         ActionChip(
// //                           avatar: const Icon(Icons.calendar_month, size: 16),
// //                           label: Text(
// //                             _selectedDateRange != null
// //                                 ? "Date Selected"
// //                                 : "Date Range",
// //                           ),
// //                           onPressed: _pickDateRange,
// //                         ),
// //                         if (_selectedDateRange != null)
// //                           IconButton(
// //                             icon: const Icon(Icons.cancel, color: Colors.red),
// //                             onPressed: () {
// //                               setState(() {
// //                                 _selectedDateRange = null;
// //                                 _applyFilters();
// //                               });
// //                             },
// //                           ),
// //                         const SizedBox(width: 8),
// //                         _buildFilterChip("All", 0),
// //                         const SizedBox(width: 8),
// //                         _buildFilterChip("Prescribed", 1),
// //                         const SizedBox(width: 8),
// //                         _buildFilterChip("Self-Added", 2),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Expanded(
// //               child:
// //                   _filteredList.isEmpty
// //                       ? const Center(child: Text("No medications match."))
// //                       : ListView.builder(
// //                         padding: const EdgeInsets.all(16),
// //                         itemCount: _filteredList.length,
// //                         itemBuilder:
// //                             (context, index) =>
// //                                 _buildMedCard(context, _filteredList[index]),
// //                       ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilterChip(String label, int index) {
// //     final isSelected = _filterSourceIndex == index;
// //     return ChoiceChip(
// //       label: Text(label),
// //       selected: isSelected,
// //       selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
// //       onSelected: (val) {
// //         if (val)
// //           setState(() {
// //             _filterSourceIndex = index;
// //             _applyFilters();
// //           });
// //       },
// //     );
// //   }

// //   Widget _buildMedCard(BuildContext context, MedicationModel item) {
// //     String dateText = "";
// //     if (item.startDate != null)
// //       dateText += "Start: ${item.startDate!.split('T')[0]}";
// //     if (item.endDate != null)
// //       dateText += " | End: ${item.endDate!.split('T')[0]}";

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(10),
// //               decoration: BoxDecoration(
// //                 color: Colors.purple.shade50,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(Icons.medication, color: Colors.purple),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     item.medicationName,
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 16,
// //                     ),
// //                   ),
// //                   Text(
// //                     "${item.dosage} - ${item.doseInstruction}",
// //                     style: const TextStyle(color: Colors.grey),
// //                   ),
// //                   if (dateText.isNotEmpty)
// //                     Text(
// //                       dateText,
// //                       style: const TextStyle(
// //                         fontSize: 11,
// //                         color: Colors.blueGrey,
// //                       ),
// //                     ),
// //                   Text(
// //                     item.isSelfMedication ? "Added by You" : "Prescribed",
// //                     style: TextStyle(
// //                       fontSize: 11,
// //                       color: item.isSelfMedication ? Colors.blue : Colors.red,
// //                       fontStyle: FontStyle.italic,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             // ✅ أزرار التعديل والحذف
// //             if (item.isSelfMedication) ...[
// //               IconButton(
// //                 icon: const Icon(Icons.edit, color: Colors.blue),
// //                 onPressed: () => _showMedicationDialog(context, item),
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.delete, color: Colors.red),
// //                 onPressed: () => _confirmDelete(context, item),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // (دوال _showMedicationDialog و _confirmDelete زي الملف التاني بالظبط، ممكن تكررهم هنا)
// //   // ملاحظة: الأفضل فصل الدالوج في ملف منفصل عشان التكرار، بس عشان الملفات الكاملة نسختهم هنا ليك.

// //   // void _showMedicationDialog(BuildContext context, MedicationModel? medToEdit) {
// //   //   // ... (انسخ نفس دالة الدالوج من الملف الأول بالظبط)
// //   // }
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
// //                         historyID: widget.historyId,
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

// //   // void _confirmDelete(BuildContext context, MedicationModel item) {
// //   //   // ... (انسخ نفس دالة الحذف من الملف الأول)
// //   // }
// //   void _confirmDelete(BuildContext context, MedicationModel item) {
// //     showDialog(
// //       context: context,
// //       builder:
// //           (ctx) => AlertDialog(
// //             title: const Text("Delete Medication"),
// //             content: Text(
// //               "Are you sure you want to delete '${item.medicationName}'?",
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(ctx),
// //                 child: const Text("Cancel"),
// //               ),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //                 onPressed: () {
// //                   // هنا تنادي دالة الحذف في الكيوبت
// //                   // context.read<PatientProfileCubit>().deleteMedication(item.currentMedicationID!);
// //                   Navigator.pop(ctx);
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text("Delete feature implementation pending"),
// //                     ),
// //                   );
// //                 },
// //                 child: const Text(
// //                   "Delete",
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
// import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_card.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_dialog.dart';
// import 'package:intl/intl.dart';

// class AllMedicationsView extends StatefulWidget {
//   final List<MedicationModel> allMedications;
//   final int historyId;
//   final PatientProfileCubit cubit;

//   const AllMedicationsView({
//     super.key,
//     required this.allMedications,
//     required this.historyId,
//     required this.cubit,
//   });

//   @override
//   State<AllMedicationsView> createState() => _AllMedicationsViewState();
// }

// class _AllMedicationsViewState extends State<AllMedicationsView> {
//   String _searchQuery = "";
//   DateTimeRange? _selectedDateRange;
//   int _filterSourceIndex = 0;

//   late List<MedicationModel> _currentList; // القائمة الحالية
//   late List<MedicationModel> _filteredList; // القائمة المفلترة

//   @override
//   void initState() {
//     super.initState();
//     _currentList = widget.allMedications;
//     _filteredList = _currentList;
//     _applyFilters();
//   }

//   void _applyFilters() {
//     setState(() {
//       _filteredList =
//           _currentList.where((med) {
//             final matchesName = med.medicationName.toLowerCase().contains(
//               _searchQuery.toLowerCase(),
//             );

//             bool matchesDate = true;
//             if (_selectedDateRange != null && med.startDate != null) {
//               final medStart = DateTime.parse(med.startDate!);
//               matchesDate =
//                   medStart.isAfter(
//                     _selectedDateRange!.start.subtract(const Duration(days: 1)),
//                   ) &&
//                   medStart.isBefore(
//                     _selectedDateRange!.end.add(const Duration(days: 1)),
//                   );
//             }

//             bool matchesSource = true;
//             if (_filterSourceIndex == 1) matchesSource = !med.isSelfMedication;
//             if (_filterSourceIndex == 2) matchesSource = med.isSelfMedication;

//             return matchesName && matchesDate && matchesSource;
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: widget.cubit,
//       child: BlocConsumer<PatientProfileCubit, PatientProfileState>(
//         listener: (context, state) {
//           // إظهار رسائل النجاح
//           if (state is PatientOperationSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//           if (state is PatientDeleteSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           // ✅✅ هنا التحديث: لو الداتا اتحدثت، ناخد القائمة الجديدة
//           // if (state is PatientProfileSuccess) {
//           //   _currentList =
//           //       state
//           //           .profile
//           //           .currentMedications; // القائمة المدمجة من الموديل الجديد

//           //   // لازم نعيد الفلترة عشان التعديل يظهر
//           //   // (استخدمنا Future.microtask عشان نتجنب setState أثناء الـ build)
//           //   // أو ببساطة نعيد حساب الفلتر هنا مباشرة للعرض
//           //   _filteredList =
//           //       _currentList.where((med) {
//           //         final matchesName = med.medicationName.toLowerCase().contains(
//           //           _searchQuery.toLowerCase(),
//           //         );
//           //         bool matchesDate = true;
//           //         if (_selectedDateRange != null && med.startDate != null) {
//           //           final medStart = DateTime.parse(med.startDate!);
//           //           matchesDate =
//           //               medStart.isAfter(
//           //                 _selectedDateRange!.start.subtract(
//           //                   const Duration(days: 1),
//           //                 ),
//           //               ) &&
//           //               medStart.isBefore(
//           //                 _selectedDateRange!.end.add(const Duration(days: 1)),
//           //               );
//           //         }
//           //         bool matchesSource = true;
//           //         if (_filterSourceIndex == 1)
//           //           matchesSource = !med.isSelfMedication;
//           //         if (_filterSourceIndex == 2)
//           //           matchesSource = med.isSelfMedication;
//           //         return matchesName && matchesDate && matchesSource;
//           //       }).toList();
//           // }
//           if (state is PatientProfileSuccess) {
//             // ❌ القديم (كان بياخد جزء واحد بس)
//             // _currentList = state.profile.currentMedications;

//             // ✅ الجديد (لازم ندمجهم تاني هنا عشان لما يحصل تحديث نشوف كله)
//             _currentList = [
//               ...state.profile.currentMedications,
//               ...state.profile.patientSelfMedications,
//             ];

//             // إعادة تطبيق الفلتر
//             _filteredList =
//                 _currentList.where((med) {
//                   final matchesName = med.medicationName.toLowerCase().contains(
//                     _searchQuery.toLowerCase(),
//                   );
//                   // ... نفس لوجيك الفلتر ...
//                   bool matchesDate = true;
//                   if (_selectedDateRange != null && med.startDate != null) {
//                     final medStart = DateTime.parse(med.startDate!);
//                     matchesDate =
//                         medStart.isAfter(
//                           _selectedDateRange!.start.subtract(
//                             const Duration(days: 1),
//                           ),
//                         ) &&
//                         medStart.isBefore(
//                           _selectedDateRange!.end.add(const Duration(days: 1)),
//                         );
//                   }
//                   bool matchesSource = true;
//                   if (_filterSourceIndex == 1)
//                     matchesSource = !med.isSelfMedication;
//                   if (_filterSourceIndex == 2)
//                     matchesSource = med.isSelfMedication;
//                   return matchesName && matchesDate && matchesSource;
//                 }).toList();
//           }
//           return Scaffold(
//             backgroundColor: const Color(0xFFF3F4F6),
//             appBar: AppBar(
//               title: const Text(
//                 "All Medications",
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
//                 // Search & Filters
//                 Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       TextField(
//                         onChanged: (val) {
//                           _searchQuery = val;
//                           _applyFilters();
//                         },
//                         decoration: InputDecoration(
//                           hintText: "Search medications...",
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: Colors.grey,
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey.shade100,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // Chips
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             // ... (نفس كود الـ Chips بتاع التاريخ والمصدر)
//                             // اختصاراً للكتابة هنا، انسخهم من الكود القديم
//                             _buildFilterChip("All", 0),
//                             const SizedBox(width: 8),
//                             _buildFilterChip("Prescribed", 1),
//                             const SizedBox(width: 8),
//                             _buildFilterChip("Self-Added", 2),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // List
//                 Expanded(
//                   child:
//                       _filteredList.isEmpty
//                           ? const Center(child: Text("No medications found."))
//                           : ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: _filteredList.length,
//                             itemBuilder: (context, index) {
//                               final item = _filteredList[index];
//                               return MedicationCard(
//                                 item: item,
//                                 onEdit:
//                                     () => MedicationDialog.show(
//                                       context,
//                                       widget.historyId,
//                                       medToEdit: item,
//                                     ),
//                                 onDelete:
//                                     () =>
//                                     //  showDeleteConfirmation(
//                                     //   context,
//                                     //   item.currentMedicationID!,
//                                     // ),
//                                     showDeleteConfirmation(
//                                       context: context,
//                                       title: "Delete Medication",
//                                       message:
//                                           "Are you sure you want to delete '${item.medicationName}'?",
//                                       onConfirm: () {
//                                         context
//                                             .read<PatientProfileCubit>()
//                                             .deleteSelfMedication(
//                                               item.currentMedicationID!,
//                                             );
//                                       },
//                                     ),
//                               );
//                             },
//                           ),
//                 ),
//               ],
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () => MedicationDialog.show(context, widget.historyId),
//               backgroundColor: const Color(0xFF9C27B0),
//               child: const Icon(Icons.add, color: Colors.white),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, int index) {
//     final isSelected = _filterSourceIndex == index;
//     return ChoiceChip(
//       label: Text(label),
//       selected: isSelected,
//       selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
//       onSelected: (val) {
//         if (val)
//           setState(() {
//             _filterSourceIndex = index;
//             _applyFilters();
//           });
//       },
//     );
//   }

//   // Future<void> _pickDate(
//   //   BuildContext context,
//   //   TextEditingController controller,
//   // ) async {
//   //   final picked = await showDatePicker(
//   //     context: context,
//   //     initialDate: DateTime.now(),
//   //     firstDate: DateTime(2000),
//   //     lastDate: DateTime(2030),
//   //   );
//   //   if (picked != null) {
//   //     controller.text = DateFormat('yyyy-MM-dd').format(picked);
//   //   }
//   // }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_dialog.dart';
import 'package:intl/intl.dart';

class AllMedicationsView extends StatefulWidget {
  final List<MedicationModel> allMedications;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllMedicationsView({
    super.key,
    required this.allMedications,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllMedicationsView> createState() => _AllMedicationsViewState();
}

class _AllMedicationsViewState extends State<AllMedicationsView> {
  String _searchQuery = "";
  DateTimeRange? _selectedDateRange;

  // 0: All, 1: Doctor (Prescribed), 2: Self
  int _filterSourceIndex = 0;

  // ✅ 0: All, 1: Active (Ongoing), 2: Completed (Finished)
  int _filterStatusIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text(
            "All Medications",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: const BackButton(color: Colors.black),
          actions: [
            // زرار التاريخ (زي العمليات)
            if (_selectedDateRange != null)
              IconButton(
                icon: const Icon(Icons.filter_alt_off, color: Colors.red),
                onPressed: () => setState(() => _selectedDateRange = null),
              ),
            IconButton(
              icon: Icon(
                Icons.calendar_month,
                color:
                    _selectedDateRange != null
                        ? const Color(0xFF9C27B0)
                        : Colors.grey,
              ),
              onPressed: _pickDateRange,
            ),
          ],
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
            if (state is PatientDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          builder: (context, state) {
            // 1. تحديد القائمة المصدر
            List<MedicationModel> currentList = widget.allMedications;
            if (state is PatientProfileSuccess) {
              currentList = [
                ...state.profile.currentMedications,
                ...state.profile.patientSelfMedications,
              ];
            }

            // 2. تطبيق الفلاتر
            final filteredList = _applyFilteringLogic(currentList);

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Search Bar ---
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search medications...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- Source Filter (Doctor vs Self) ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              "Source: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            _buildFilterChip(
                              "All",
                              0,
                              _filterSourceIndex,
                              (val) => _filterSourceIndex = val,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              "Doctor",
                              1,
                              _filterSourceIndex,
                              (val) => _filterSourceIndex = val,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              "Self",
                              2,
                              _filterSourceIndex,
                              (val) => _filterSourceIndex = val,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- ✅ Status Filter (Active vs Completed) ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              "Status: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            _buildFilterChip(
                              "All",
                              0,
                              _filterStatusIndex,
                              (val) => _filterStatusIndex = val,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              "Active",
                              1,
                              _filterStatusIndex,
                              (val) => _filterStatusIndex = val,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              "Completed",
                              2,
                              _filterStatusIndex,
                              (val) => _filterStatusIndex = val,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Date Range Indicator ---
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(
                            "${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF9C27B0),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onDeleted:
                              () => setState(() => _selectedDateRange = null),
                        ),
                      ],
                    ),
                  ),

                // --- List ---
                Expanded(
                  child:
                      filteredList.isEmpty
                          ? const Center(
                            child: Text(
                              "No medications found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return MedicationCard(
                                item: item,
                                onEdit:
                                    () => MedicationDialog.show(
                                      context,
                                      widget.historyId,
                                      widget.cubit,
                                      medToEdit: item,
                                    ),
                                onDelete:
                                    () => showDeleteConfirmation(
                                      context: context,
                                      title: "Delete Medication",
                                      message:
                                          "Are you sure you want to delete '${item.medicationName}'?",
                                      onConfirm: () {
                                        context
                                            .read<PatientProfileCubit>()
                                            .deleteSelfMedication(
                                              item.currentMedicationID!,
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
              () => MedicationDialog.show(
                context,
                widget.historyId,
                widget.cubit,
              ),
          backgroundColor: const Color(0xFF9C27B0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // ✅ دالة الفلترة المجمعة
  List<MedicationModel> _applyFilteringLogic(List<MedicationModel> list) {
    return list.where((med) {
      final now = DateTime.now();

      // 1. Search Filter
      final matchesName = med.medicationName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // 2. Source Filter
      bool matchesSource = true;
      if (_filterSourceIndex == 1)
        matchesSource = !med.isSelfMedication; // Doctor only
      if (_filterSourceIndex == 2)
        matchesSource = med.isSelfMedication; // Self only

      // 3. ✅ Status Filter (Active vs Completed)
      bool matchesStatus = true;
      DateTime? endDate;
      if (med.endDate != null) endDate = DateTime.tryParse(med.endDate!);

      if (_filterStatusIndex == 1) {
        // Active: End date is null OR End date is in the future
        matchesStatus = endDate == null || endDate.isAfter(now);
      }
      if (_filterStatusIndex == 2) {
        // Completed: End date exists AND is in the past
        matchesStatus = endDate != null && endDate.isBefore(now);
      }

      // 4. ✅ Date Range Filter
      bool matchesDateRange = true;
      if (_selectedDateRange != null && med.startDate != null) {
        final medStart = DateTime.parse(med.startDate!);
        // نعتبر الدواء مستمر للمستقبل لو ملوش تاريخ انتهاء
        final medEnd = endDate ?? DateTime(2100);

        // تداخل الفترات (Overlap Logic)
        // الدواء بيظهر لو فترته تتقاطع مع الفترة المختارة
        matchesDateRange =
            medStart.isBefore(_selectedDateRange!.end) &&
            medEnd.isAfter(_selectedDateRange!.start);
      }

      return matchesName && matchesSource && matchesStatus && matchesDateRange;
    }).toList();
  }

  Widget _buildFilterChip(
    String label,
    int index,
    int groupValue,
    Function(int) onSelected,
  ) {
    final isSelected = groupValue == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF7B1FA2) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (val) {
        if (val) setState(() => onSelected(index));
      },
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // نسمح باختيار تاريخ مستقبلي للأدوية
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF9C27B0)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }
}

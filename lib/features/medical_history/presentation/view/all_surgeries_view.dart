import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_dialog.dart';
import 'package:intl/intl.dart';

class AllSurgeriesView extends StatefulWidget {
  final List<SurgeryModel> allSurgeries;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllSurgeriesView({
    super.key,
    required this.allSurgeries,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllSurgeriesView> createState() => _AllSurgeriesViewState();
}

class _AllSurgeriesViewState extends State<AllSurgeriesView> {
  String _searchQuery = "";
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text(
            "All Surgeries",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: const BackButton(color: Colors.black),
          actions: [
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
                        ? const Color(0xFF2563EB)
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
          },
          builder: (context, state) {
            // 1. تحديد المصدر
            List<SurgeryModel> currentList = widget.allSurgeries;
            if (state is PatientProfileSuccess) {
              currentList = state.profile.surgeries;
            }

            // 2. تطبيق الفلترة
            final filteredList =
                currentList.where((surgery) {
                  final matchesSearch = surgery.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

                  bool matchesDate = true;
                  if (_selectedDateRange != null && surgery.date != null) {
                    final surgeryDate = DateTime.parse(surgery.date!);
                    matchesDate =
                        surgeryDate.isAfter(
                          _selectedDateRange!.start.subtract(
                            const Duration(days: 1),
                          ),
                        ) &&
                        surgeryDate.isBefore(
                          _selectedDateRange!.end.add(const Duration(days: 1)),
                        );
                  }
                  return matchesSearch && matchesDate;
                }).toList();

            // ترتيب حسب التاريخ
            filteredList.sort((a, b) => (b.date ?? "").compareTo(a.date ?? ""));

            return Column(
              children: [
                // --- Search Bar ---
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search surgeries...",
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

                // --- Date Filter Chip ---
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
                            "${DateFormat('MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM yyyy').format(_selectedDateRange!.end)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF2563EB),
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
                              "No surgeries found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return SurgeryCard(
                                surgery: item,
                                onEdit:
                                    () => SurgeryDialog.show(
                                      context,
                                      widget.historyId,
                                      widget.cubit,
                                      surgeryToEdit: item,
                                    ),
                                onDelete:
                                    () => showDeleteConfirmation(
                                      context: context,
                                      title: "Delete Surgery",
                                      message:
                                          "Are you sure you want to delete '${item.name}'?",
                                      onConfirm: () {
                                        context
                                            .read<PatientProfileCubit>()
                                            .deleteSurgery(
                                              item.surgeryID!,
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
              () => SurgeryDialog.show(context, widget.historyId, widget.cubit),
          backgroundColor: const Color(0xFF2563EB),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}

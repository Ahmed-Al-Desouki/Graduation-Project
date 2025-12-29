import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/lab_result_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_file_upload_dialog.dart';
import 'package:intl/intl.dart';

class AllLabResultsView extends StatefulWidget {
  final List<MedicalFileModel> labTests;
  final List<MedicalFileModel> radiologyFiles;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllLabResultsView({
    super.key,
    required this.labTests,
    required this.radiologyFiles,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllLabResultsView> createState() => _AllLabResultsViewState();
}

class _AllLabResultsViewState extends State<AllLabResultsView> {
  String _searchQuery = "";
  DateTimeRange? _selectedDateRange;
  int _filterTypeIndex = 0; // 0: All, 1: Lab, 2: Radiology

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text(
            "Medical Files",
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
                        ? const Color(0xFF06B6D4)
                        : Colors.grey,
              ),
              onPressed: _pickDateRange,
            ),
          ],
        ),
        body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is PatientUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("File uploaded successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is PatientDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("File deleted."),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          builder: (context, state) {
            // 1. Prepare Lists based on State
            List<MedicalFileModel> currentLabs = widget.labTests;
            List<MedicalFileModel> currentRads = widget.radiologyFiles;

            if (state is PatientProfileSuccess) {
              currentLabs = state.profile.labTests;
              currentRads = state.profile.radiologyFiles;
            }

            // 2. Merge & Convert to View Model
            final List<LabResultModel> combinedList = [
              ...currentLabs.map(
                (e) => LabResultModel(
                  id: e.fileID.toString(),
                  title: e.description.isEmpty ? "Lab Test" : e.description,
                  date: e.uploadedAt.split('T')[0],
                  type: RecordType.lab,
                  fileName: e.fileUrl,
                ),
              ),
              ...currentRads.map(
                (e) => LabResultModel(
                  id: e.fileID.toString(),
                  title: e.description.isEmpty ? "Radiology" : e.description,
                  date: e.uploadedAt.split('T')[0],
                  type: RecordType.radiology,
                  fileName: e.fileUrl,
                ),
              ),
            ];

            // 3. Apply Filters
            final filteredList =
                combinedList.where((item) {
                  // Search
                  final matchesSearch = item.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

                  // Date
                  bool matchesDate = true;
                  if (_selectedDateRange != null) {
                    final itemDate = DateTime.parse(item.date);
                    matchesDate =
                        itemDate.isAfter(
                          _selectedDateRange!.start.subtract(
                            const Duration(days: 1),
                          ),
                        ) &&
                        itemDate.isBefore(
                          _selectedDateRange!.end.add(const Duration(days: 1)),
                        );
                  }

                  // Type (Category)
                  bool matchesType = true;
                  if (_filterTypeIndex == 1)
                    matchesType = item.type == RecordType.lab;
                  if (_filterTypeIndex == 2)
                    matchesType = item.type == RecordType.radiology;

                  return matchesSearch && matchesDate && matchesType;
                }).toList();

            // Sort descending
            filteredList.sort((a, b) => b.date.compareTo(a.date));

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search files...",
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

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildChip("All", 0),
                            const SizedBox(width: 8),
                            _buildChip("Lab Results", 1),
                            const SizedBox(width: 8),
                            _buildChip("Radiology", 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Date Chip Indicator
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
                            "${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF06B6D4),
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

                // List
                Expanded(
                  child:
                      filteredList.isEmpty
                          ? const Center(
                            child: Text(
                              "No files found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return LabResultCard(
                                result: item,
                                onDelete:
                                    () => showDeleteConfirmation(
                                      context: context,
                                      title: "Delete File",
                                      message:
                                          "Are you sure you want to delete '${item.title}'?",
                                      onConfirm: () {
                                        context
                                            .read<PatientProfileCubit>()
                                            .deleteMedicalFile(
                                              int.parse(item.id),
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
              () => MedicalFileUploadDialog.show(
                context,
                widget.historyId,
                widget.cubit,
              ),
          backgroundColor: const Color(0xFF06B6D4),
          child: const Icon(Icons.cloud_upload, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    final isSelected = _filterTypeIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF06B6D4).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00838F) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) setState(() => _filterTypeIndex = index);
      },
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF06B6D4)),
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

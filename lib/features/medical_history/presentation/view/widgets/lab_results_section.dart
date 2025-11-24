// features/medical_history/presentation/view/widgets/lab_results_section.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:intl/intl.dart';
import 'lab_result_card.dart';

class LabResultsSection extends StatefulWidget {
  final List<MedicalFileModel> labTests;
  final List<MedicalFileModel> radiologyFiles;
  final int medicalHistoryId;
  const LabResultsSection({
    super.key,
    required this.labTests,
    required this.radiologyFiles,
    required this.medicalHistoryId,
  });

  @override
  State<LabResultsSection> createState() => _LabResultsSectionState();
}

class _LabResultsSectionState extends State<LabResultsSection> {
  // قائمة البيانات (فاضية في البداية أو فيها داتا وهمية)
  // final List<LabResultModel> _results = [];

  @override
  Widget build(BuildContext context) {
    final List<LabResultModel> displayList = [
      ...widget.labTests.map(
        (e) => LabResultModel(
          id: e.fileID.toString(),
          title: e.description.isEmpty ? "Lab Test" : e.description,
          date: e.uploadedAt.split('T')[0],
          type: RecordType.lab,
          fileName: e.fileUrl,
        ),
      ),
      ...widget.radiologyFiles.map(
        (e) => LabResultModel(
          id: e.fileID.toString(),
          title: e.description.isEmpty ? "Radiology" : e.description,
          date: e.uploadedAt.split('T')[0],
          type: RecordType.radiology,
          fileName: e.fileUrl,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFEFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Lab Results & Radiology",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // List
          if (displayList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No records uploaded yet.",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...displayList.map(
              (item) => LabResultCard(
                result: item,
                onDelete: () {
                  // استدعاء الحذف من الكيوبت
                  context.read<PatientProfileCubit>().deleteMedicalFile(
                    int.parse(item.id),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "Upload New Record",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => _UploadForm(
            medicalHistoryId: widget.medicalHistoryId,
            parentContext: context,
          ),
    );
  }
}

class _UploadForm extends StatefulWidget {
  final int medicalHistoryId;
  final BuildContext parentContext;
  const _UploadForm({
    required this.medicalHistoryId,
    required this.parentContext,
  });

  @override
  State<_UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<_UploadForm> {
  final _titleController = TextEditingController();
  RecordType _selectedType = RecordType.lab;
  File? _pickedFile;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomPadding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add New Record",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Description",
              hintText: "e.g. CBC Blood Test",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Category",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTypeSelector(
                  "Lab Result",
                  RecordType.lab,
                  Icons.science,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeSelector(
                  "Radiology",
                  RecordType.radiology,
                  Icons.document_scanner,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _pickedFile != null
                        ? Icons.check_circle
                        : Icons.upload_file,
                    color: _pickedFile != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _pickedFile != null
                          ? _pickedFile!.path.split('/').last
                          : "Tap to select file (PDF/Img)",
                      style: TextStyle(
                        color:
                            _pickedFile != null ? Colors.black87 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
              bloc: widget.parentContext.read<PatientProfileCubit>(),
              builder: (context, state) {
                if (state is PatientUploadLoading) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: null,
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _pickedFile != null) {
                      widget.parentContext
                          .read<PatientProfileCubit>()
                          .uploadMedicalFile(
                            file: _pickedFile!,
                            medicalHistoryId: widget.medicalHistoryId,
                            category:
                                _selectedType == RecordType.lab
                                    ? "LabTest"
                                    : "Radiology",
                            description: _titleController.text,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Upload Now",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Widget _buildTypeSelector(String label, RecordType type, IconData icon) {
    final isSelected = _selectedType == type;
    final color = isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300;
    final bgColor = isSelected ? const Color(0xFFEFF6FF) : Colors.white;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

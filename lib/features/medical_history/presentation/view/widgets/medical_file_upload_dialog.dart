import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart'; // عشان الـ RecordType
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';

class MedicalFileUploadDialog {
  static void show(
    BuildContext context,
    int historyId,
    PatientProfileCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => BlocProvider.value(
            value: cubit,
            child: _UploadSheet(historyId: historyId),
          ),
    );
  }
}

class _UploadSheet extends StatefulWidget {
  final int historyId;
  const _UploadSheet({required this.historyId});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _descController = TextEditingController();
  RecordType _selectedType = RecordType.lab;
  File? _pickedFile;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upload New Record",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          MedicalTextField(
            controller: _descController,
            label: "Description",
            hint: "e.g. CBC Blood Test",
            icon: Icons.description,
            isRequired: true,
          ),

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
                color:
                    _pickedFile != null
                        ? const Color(0xFFF0FDF4)
                        : Colors.grey.shade50,
                border: Border.all(
                  color:
                      _pickedFile != null ? Colors.green : Colors.grey.shade300,
                ),
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
            child: BlocConsumer<PatientProfileCubit, PatientProfileState>(
              listener: (context, state) {
                // TODO: implement listener
                if (state is PatientUploadSuccess) {
                  Navigator.pop(context);
                } else if (state is PatientUploadFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Upload Failed: ${state.errMessage}"),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PatientUploadLoading) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A).withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: null,
                    child: const CircularProgressIndicator(color: Colors.white),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_descController.text.isNotEmpty &&
                        _pickedFile != null) {
                      context.read<PatientProfileCubit>().uploadMedicalFile(
                        file: _pickedFile!,
                        medicalHistoryId: widget.historyId,
                        category:
                            _selectedType == RecordType.lab
                                ? "Lab Test"
                                : "Radiology",
                        description: _descController.text,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select a file and enter description",
                          ),
                        ),
                      );
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

  Widget _buildTypeSelector(String label, RecordType type, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }
}

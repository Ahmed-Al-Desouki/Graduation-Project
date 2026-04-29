import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_verification_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/verification_documents_tile.dart';

class VerificationDocumentsSection extends StatelessWidget {
  final List<VerificationDocumentProfileEntity> documents;
  const VerificationDocumentsSection({super.key, required this.documents});

  IconData _getIcon(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return Icons.description;
      case DocumentType.graduationCertificate:
        return Icons.school;
      case DocumentType.nationalId:
        return Icons.badge;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getColor(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return Colors.purple;
      case DocumentType.graduationCertificate:
        return Colors.blue;
      case DocumentType.nationalId:
        return Colors.green;
      case DocumentType.other:
        return Colors.grey;
    }
  }

  String _getTitle(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return "Medical License";
      case DocumentType.graduationCertificate:
        return "Graduation Certificate";
      case DocumentType.nationalId:
        return "National ID";
      case DocumentType.other:
        return "Other Document";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Verification Documents",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _showEditVerificationSheet(context, documents);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF2563EB), size: 17),
                        SizedBox(width: 5),
                        Text(
                          "Edit",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              if (documents.isEmpty)
                const Text(
                  "No documents uploaded yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ...documents.asMap().entries.map((entry) {
                final doc = entry.value;
                return Column(
                  children: [
                    VerificationDocumentsTile(
                      icon: _getIcon(doc.documentType),
                      color: _getColor(doc.documentType),
                      title: _getTitle(doc.documentType),
                      fileUrl: doc.fileUrl,
                    ),
                    if (entry.key < documents.length - 1)
                      const SizedBox(height: 15),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditVerificationSheet(
    BuildContext context,
    List<VerificationDocumentProfileEntity> documents,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<DoctorRealProfileCubit>(),
            child: EditVerificationSheet(documents: documents),
          ),
    );
  }
}

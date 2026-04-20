import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class EditVerificationSheet extends StatelessWidget {
  final List<VerificationDocumentProfileEntity> documents;
  const EditVerificationSheet({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...documents.map((doc) {
            return _buildDocumentItem(context, doc);
          }).toList(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    VerificationDocumentProfileEntity doc,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _getIconColor(doc.documentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForDocumentType(doc.documentType),
              color: _getIconColor(doc.documentType),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitleForDocumentType(doc.documentType),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () {
                final cubit = context.read<DoctorRealProfileCubit>();
                Navigator.of(context).pop();

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                  );
                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    await cubit.replaceVerificationDocument(
                      verificationId: doc.verificationId!,
                      newFile: file,
                    );
                  }

                  await cubit.getDoctorProfile();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForDocumentType(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return Icons.description;
      case DocumentType.graduationCertificate:
        return Icons.school;
      case DocumentType.nationalId:
        return Icons.badge;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getIconColor(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return Colors.purple;
      case DocumentType.graduationCertificate:
        return Colors.blue;
      case DocumentType.nationalId:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTitleForDocumentType(DocumentType type) {
    switch (type) {
      case DocumentType.license:
        return 'Medical License';
      case DocumentType.graduationCertificate:
        return 'Graduation Certificate';
      case DocumentType.nationalId:
        return 'National ID';
      default:
        return 'Other Document';
    }
  }
}

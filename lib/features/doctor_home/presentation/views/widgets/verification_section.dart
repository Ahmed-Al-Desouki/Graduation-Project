import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/verification_document_entity.dart'
    as onboarding_document;
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart'
    as profile_document;
import 'upload_document_item.dart';

class VerificationSection extends StatefulWidget {
  final List<profile_document.VerificationDocumentProfileEntity>
  existingDocuments;

  const VerificationSection({super.key, this.existingDocuments = const []});

  @override
  State<VerificationSection> createState() => VerificationSectionState();
}

class VerificationSectionState extends State<VerificationSection> {
  final Map<onboarding_document.DocumentType, File?> _selectedFiles = {};

  Map<onboarding_document.DocumentType, File?> get selectedFiles =>
      Map.unmodifiable(_selectedFiles);

  Future<void> _pickDocument(onboarding_document.DocumentType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = File(result.files.first.path!);
    final fileSize = result.files.first.size;
    if (!mounted) {
      return;
    }

    if (fileSize > 10 * 1024 * 1024) {
      showSnackBar(
        context,
        'File size must be less than 10MB. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
        Colors.red,
      );
      return;
    }

    setState(() {
      _selectedFiles[type] = file;
    });
  }

  void _clearSelection(onboarding_document.DocumentType type) {
    setState(() {
      _selectedFiles.remove(type);
    });
  }

  profile_document.VerificationDocumentProfileEntity? _existingDocumentForType(
    onboarding_document.DocumentType type,
  ) {
    final expectedType = _profileTypeFor(type);

    for (final document in widget.existingDocuments) {
      if (document.documentType == expectedType) {
        return document;
      }
    }

    return null;
  }

  profile_document.DocumentType _profileTypeFor(
    onboarding_document.DocumentType type,
  ) {
    switch (type) {
      case onboarding_document.DocumentType.license:
        return profile_document.DocumentType.license;
      case onboarding_document.DocumentType.graduationCertificate:
        return profile_document.DocumentType.graduationCertificate;
      case onboarding_document.DocumentType.nationalId:
        return profile_document.DocumentType.nationalId;
      case onboarding_document.DocumentType.other:
        return profile_document.DocumentType.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: const Color(0xFF1B4E8C),
                size: 25.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Verification Documents',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Upload the required documents for verification. Existing documents stay on your profile unless you replace them.',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          UploadDocumentItem(
            icon: Icons.description,
            label: 'Medical License',
            existingDocument: _existingDocumentForType(
              onboarding_document.DocumentType.license,
            ),
            selectedFile:
                _selectedFiles[onboarding_document.DocumentType.license],
            onUpload:
                () => _pickDocument(onboarding_document.DocumentType.license),
            onClearSelection:
                () => _clearSelection(onboarding_document.DocumentType.license),
          ),
          SizedBox(height: 20.h),
          UploadDocumentItem(
            icon: Icons.school,
            label: 'Graduation Certificate',
            existingDocument: _existingDocumentForType(
              onboarding_document.DocumentType.graduationCertificate,
            ),
            selectedFile:
                _selectedFiles[onboarding_document
                    .DocumentType
                    .graduationCertificate],
            onUpload:
                () => _pickDocument(
                  onboarding_document.DocumentType.graduationCertificate,
                ),
            onClearSelection:
                () => _clearSelection(
                  onboarding_document.DocumentType.graduationCertificate,
                ),
          ),
          SizedBox(height: 20.h),
          UploadDocumentItem(
            icon: Icons.badge,
            label: 'National ID',
            existingDocument: _existingDocumentForType(
              onboarding_document.DocumentType.nationalId,
            ),
            selectedFile:
                _selectedFiles[onboarding_document.DocumentType.nationalId],
            onUpload:
                () =>
                    _pickDocument(onboarding_document.DocumentType.nationalId),
            onClearSelection:
                () => _clearSelection(
                  onboarding_document.DocumentType.nationalId,
                ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'All 3 documents are required for admin approval',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

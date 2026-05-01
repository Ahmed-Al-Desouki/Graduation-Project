import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/empty_document_card.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/existing_document_card.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/selected_file_card.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart';

class UploadDocumentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VerificationDocumentProfileEntity? existingDocument;
  final VoidCallback onUpload;
  final File? selectedFile;
  final VoidCallback? onClearSelection;

  const UploadDocumentItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onUpload,
    this.existingDocument,
    this.selectedFile,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedFile = selectedFile != null;
    final hasExistingDocument = existingDocument != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1B4E8C), size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4E8C),
                  ),
                ),
              ),
              if (hasExistingDocument)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          if (hasSelectedFile)
            SelectedFileCard(
              file: selectedFile!,
              onClearSelection: onClearSelection,
            )
          else if (hasExistingDocument)
            ExistingDocumentCard(document: existingDocument!)
          else
            EmptyDocumentCard(onUpload: onUpload),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpload,
              icon: Icon(
                hasExistingDocument ? Icons.refresh : Icons.upload_file,
                size: 18.sp,
              ),
              label: Text(
                hasSelectedFile
                    ? 'Choose Another File'
                    : hasExistingDocument
                    ? 'Replace Document'
                    : 'Upload Document',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B4E8C),
                side: const BorderSide(color: Color(0xFF1B4E8C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          if (hasSelectedFile) ...[
            SizedBox(height: 8.h),
            Text(
              hasExistingDocument
                  ? 'The selected file will replace the current document after you submit the profile.'
                  : 'This file will be uploaded when you submit the profile.',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _statusLabel {
    switch (existingDocument?.status) {
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.pending:
      case null:
        return 'Pending';
    }
  }

  Color get _statusColor {
    switch (existingDocument?.status) {
      case VerificationStatus.approved:
        return const Color(0xFF047857);
      case VerificationStatus.rejected:
        return const Color(0xFFB91C1C);
      case VerificationStatus.pending:
      case null:
        return const Color(0xFF1D4ED8);
    }
  }

  Color get _backgroundColor {
    if (selectedFile != null) {
      return const Color(0xFFDBEAFE);
    }

    switch (existingDocument?.status) {
      case VerificationStatus.approved:
        return const Color(0xFFD1FAE5);
      case VerificationStatus.rejected:
        return const Color(0xFFFEE2E2);
      case VerificationStatus.pending:
        return const Color(0xFFEFF6FF);
      case null:
        return const Color(0xFFF9FAFB);
    }
  }

  Color get _borderColor {
    if (selectedFile != null) {
      return const Color(0xFF1B4E8C);
    }

    switch (existingDocument?.status) {
      case VerificationStatus.approved:
        return const Color(0xFF10B981);
      case VerificationStatus.rejected:
        return const Color(0xFFEF4444);
      case VerificationStatus.pending:
        return const Color(0xFF3B82F6);
      case null:
        return const Color(0xFFE5E7EB);
    }
  }
}

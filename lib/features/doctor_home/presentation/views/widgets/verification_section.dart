import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/upload_document_item.dart';

class VerificationSection extends StatelessWidget {
  final bool medicalLicenseUploaded;
  final bool graduationCertUploaded;
  final bool nationalIdUploaded;
  final Function(String) onDocumentUploaded;

  const VerificationSection({
    super.key,
    required this.medicalLicenseUploaded,
    required this.graduationCertUploaded,
    required this.nationalIdUploaded,
    required this.onDocumentUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                "Verification Documents",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          UploadDocumentItem(
            icon: Icons.description,
            label: 'Medical License',
            isUploaded: medicalLicenseUploaded,
            onUpload: () => onDocumentUploaded('medical'),
          ),
          SizedBox(height: 12.h),
          UploadDocumentItem(
            icon: Icons.school,
            label: 'Graduation Certificate',
            isUploaded: graduationCertUploaded,
            onUpload: () => onDocumentUploaded('graduation'),
          ),
          SizedBox(height: 12.h),
          UploadDocumentItem(
            icon: Icons.badge,
            label: 'National ID',
            isUploaded: nationalIdUploaded,
            onUpload: () => onDocumentUploaded('national'),
          ),
          SizedBox(height: 8.h),
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

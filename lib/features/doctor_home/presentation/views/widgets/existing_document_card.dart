import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart';

class ExistingDocumentCard extends StatelessWidget {
  final VerificationDocumentProfileEntity document;
  const ExistingDocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Color(0xFF1B4E8C)),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Current document on file',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          if (document.submittedAt != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Submitted on ${document.submittedAt!.day.toString().padLeft(2, '0')}/${document.submittedAt!.month.toString().padLeft(2, '0')}/${document.submittedAt!.year}',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
            ),
          ],
          if (document.adminNotes?.trim().isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Text(
              'Admin note: ${document.adminNotes!}',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

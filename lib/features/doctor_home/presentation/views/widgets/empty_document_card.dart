import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyDocumentCard extends StatelessWidget {
  final VoidCallback onUpload;
  const EmptyDocumentCard({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 36.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap to upload document',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 4.h),
            Text(
              'PDF, JPG, PNG (max: 10MB)',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}

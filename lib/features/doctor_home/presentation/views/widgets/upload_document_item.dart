import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadDocumentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUploaded;
  final VoidCallback onUpload;

  const UploadDocumentItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color:
                  isUploaded
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : icon,
              size: 22.sp,
              color:
                  isUploaded
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1B4E8C),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color:
                    isUploaded
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 16.sp,
                    color:
                        isUploaded
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1B4E8C),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    isUploaded ? 'Uploaded' : 'Upload',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          isUploaded
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1B4E8C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

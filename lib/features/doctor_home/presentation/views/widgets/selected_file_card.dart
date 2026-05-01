import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedFileCard extends StatelessWidget {
  final File file;
  final VoidCallback? onClearSelection;
  const SelectedFileCard({
    super.key,
    required this.file,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _fileTypeIcon(file),
              size: 22.sp,
              color: const Color(0xFF1B4E8C),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path.split('/').last,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  file.path.split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (onClearSelection != null)
            IconButton(
              onPressed: onClearSelection,
              icon: Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  IconData _fileTypeIcon(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return Icons.picture_as_pdf;
    }

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return Icons.image;
    }

    return Icons.insert_drive_file;
  }
}

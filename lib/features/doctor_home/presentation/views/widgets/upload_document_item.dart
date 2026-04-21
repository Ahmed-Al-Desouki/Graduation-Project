import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadDocumentItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isUploaded;
  final VoidCallback onUpload;
  final File? selectedFile;
  final Function(File?)? onFileSelected;

  const UploadDocumentItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.onUpload,
    this.selectedFile,
    this.onFileSelected,
  });

  @override
  State<UploadDocumentItem> createState() => _UploadDocumentItemState();
}

class _UploadDocumentItemState extends State<UploadDocumentItem> {
  // ✅ Get file name from path
  String _getFileName() {
    if (widget.selectedFile == null) return '';
    return widget.selectedFile!.path.split('/').last;
  }

  // ✅ Get file extension
  String _getFileExtension() {
    if (widget.selectedFile == null) return '';
    return widget.selectedFile!.path.split('.').last.toUpperCase();
  }

  // ✅ Get file type icon
  IconData _getFileTypeIcon() {
    final ext = _getFileExtension().toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['jpg', 'jpeg', 'png'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedFile = widget.selectedFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Document Title with Icon
        Row(
          children: [
            Icon(widget.icon, color: const Color(0xFF1B4E8C), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B4E8C),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        GestureDetector(
          onTap: hasSelectedFile || widget.isUploaded ? null : widget.onUpload,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ 1. File Preview (لو فيه ملف مختار)
                if (hasSelectedFile) ...[
                  // File Info Card
                  SizedBox(height: 12.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // File Icon
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getFileTypeIcon(),
                            size: 24.sp,
                            color: const Color(0xFF1B4E8C),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // File Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFileName(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getFileExtension(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B4E8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ✅ Remove Button (زي الـ Achievement)
                        GestureDetector(
                          onTap: () {
                            if (widget.onFileSelected != null) {
                              widget.onFileSelected!(null);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ]
                // ✅ 2. Upload Prompt (لو مفيش ملف)
                else ...[
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap to upload document',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'PDF, JPG, PNG (max: 10MB)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Helper Methods
  Color _getBackgroundColor() {
    if (widget.isUploaded) return const Color(0xFFD1FAE5);
    if (widget.selectedFile != null) return const Color(0xFFDBEAFE);
    return const Color(0xFFF3F4F6);
  }

  Color _getBorderColor() {
    if (widget.isUploaded) return const Color(0xFF10B981);
    if (widget.selectedFile != null) return const Color(0xFF1B4E8C);
    return const Color(0xFFE5E7EB);
  }
}

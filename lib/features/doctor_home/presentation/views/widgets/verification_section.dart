import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'upload_document_item.dart';

class VerificationSection extends StatefulWidget {
  final bool medicalLicenseUploaded;
  final bool graduationCertUploaded;
  final bool nationalIdUploaded;
  final Function(String, File?) onFileSelected;
  final Function(String) onUpload;

  const VerificationSection({
    super.key,
    required this.medicalLicenseUploaded,
    required this.graduationCertUploaded,
    required this.nationalIdUploaded,
    required this.onFileSelected,
    required this.onUpload,
  });

  @override
  State<VerificationSection> createState() => _VerificationSectionState();
}

class _VerificationSectionState extends State<VerificationSection> {
  File? _medicalLicenseFile;
  File? _graduationCertFile;
  File? _nationalIdFile;
  // ✅ Handle File Selection
  void _onFileSelected(String type, File? file) {
    setState(() {
      switch (type) {
        case 'medical':
          _medicalLicenseFile = file;
          break;
        case 'graduation':
          _graduationCertFile = file;
          break;
        case 'national':
          _nationalIdFile = file;
          break;
      }
    });
  }

  // ✅ Pick Document Function
  Future<void> _pickDocument(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);
    final fileSize = result.files.first.size;

    // ✅ Validate file size (Max 10MB)
    if (fileSize > 10 * 1024 * 1024) {
      showSnackBar(
        context,
        'File size must be less than 10MB. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
        Colors.red,
      );
      return;
    }

    // ✅ Notify parent about file selection
    _onFileSelected(type, file);

    // ✅ Call Cubit upload method
    await widget.onUpload(type);

    showSnackBar(context, 'Document uploaded successfully', Colors.green);
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
          Text(
            'Upload required documents for admin verification. Each document can only be submitted once.',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),

          // ✅ Medical License
          UploadDocumentItem(
            icon: Icons.description,
            label: 'Medical License',
            isUploaded: widget.medicalLicenseUploaded,
            selectedFile: _medicalLicenseFile,
            onFileSelected: (file) => _onFileSelected('medical', file),
            onUpload: () => _pickDocument('medical'),
          ),
          SizedBox(height: 20.h),

          // ✅ Graduation Certificate
          UploadDocumentItem(
            icon: Icons.school,
            label: 'Graduation Certificate',
            isUploaded: widget.graduationCertUploaded,
            selectedFile: _graduationCertFile,
            onFileSelected: (file) => _onFileSelected('graduation', file),
            onUpload: () => _pickDocument('graduation'),
          ),
          SizedBox(height: 20.h),

          // ✅ National ID
          UploadDocumentItem(
            icon: Icons.badge,
            label: 'National ID',
            isUploaded: widget.nationalIdUploaded,
            selectedFile: _nationalIdFile,
            onFileSelected: (file) => _onFileSelected('national', file),
            onUpload: () => _pickDocument('national'),
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
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
// import 'upload_document_item.dart';

// class VerificationSection extends StatefulWidget {
//   final bool medicalLicenseUploaded;
//   final bool graduationCertUploaded;
//   final bool nationalIdUploaded;

//   const VerificationSection({
//     super.key,
//     required this.medicalLicenseUploaded,
//     required this.graduationCertUploaded,
//     required this.nationalIdUploaded,
//   });

//   @override
//   State<VerificationSection> createState() => _VerificationSectionState();
// }

// class _VerificationSectionState extends State<VerificationSection> {
//   // ✅ Selected Files (قبل الـ Upload)
//   File? _medicalLicenseFile;
//   File? _graduationCertFile;
//   File? _nationalIdFile;

//   // ✅ Handle File Selection
//   void _onFileSelected(String type, File? file) {
//     setState(() {
//       switch (type) {
//         case 'medical':
//           _medicalLicenseFile = file;
//           break;
//         case 'graduation':
//           _graduationCertFile = file;
//           break;
//         case 'national':
//           _nationalIdFile = file;
//           break;
//       }
//     });
//   }

//   // ✅ Pick Document Function (نقلت الدالة هنا)
//   Future<void> _pickDocument(String type) async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
//       allowMultiple: false,
//     );

//     if (result == null || result.files.isEmpty) return;

//     final file = File(result.files.first.path!);
//     final fileSize = result.files.first.size;

//     // ✅ Validate file size (Max 10MB)
//     if (fileSize > 10 * 1024 * 1024) {
//       showSnackBar(
//         context,
//         'File size must be less than 10MB. Current size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
//         Colors.red,
//       );
//       return;
//     }

//     // ✅ نمرر الملف للـ UploadDocumentItem
//     _onFileSelected(type, file);

//     showSnackBar(context, 'Document uploaded successfully', Colors.green);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.verified_user,
//                 color: const Color(0xFF1B4E8C),
//                 size: 25.sp,
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 "Verification Documents",
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'Upload required documents for admin verification. Each document can only be submitted once.',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: const Color(0xFF6B7280),
//               height: 1.5,
//             ),
//           ),
//           SizedBox(height: 24.h),

//           UploadDocumentItem(
//             icon: Icons.description,
//             label: 'Medical License',
//             isUploaded: widget.medicalLicenseUploaded,
//             selectedFile: _medicalLicenseFile, // ✅ الملف هيظهر هنا
//             onFileSelected: (file) => _onFileSelected('medical', file),
//             onUpload: () => _pickDocument('medical'), // ✅ الدالة الجديدة
//           ),
//           SizedBox(height: 20.h),

//           UploadDocumentItem(
//             icon: Icons.school,
//             label: 'Graduation Certificate',
//             isUploaded: widget.graduationCertUploaded,
//             selectedFile: _graduationCertFile, // ✅ الملف هيظهر هنا
//             onFileSelected: (file) => _onFileSelected('graduation', file),
//             onUpload: () => _pickDocument('graduation'), // ✅ الدالة الجديدة
//           ),
//           SizedBox(height: 20.h),

//           UploadDocumentItem(
//             icon: Icons.badge,
//             label: 'National ID',
//             isUploaded: widget.nationalIdUploaded,
//             selectedFile: _nationalIdFile, // ✅ الملف هيظهر هنا
//             onFileSelected: (file) => _onFileSelected('national', file),
//             onUpload: () => _pickDocument('national'), // ✅ الدالة الجديدة
//           ),
//           SizedBox(height: 16.h),

//           Center(
//             child: Text(
//               'All 3 documents are required for admin approval',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: const Color(0xFF9CA3AF),
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

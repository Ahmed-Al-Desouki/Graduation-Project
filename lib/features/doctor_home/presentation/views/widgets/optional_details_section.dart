import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/confirm_delete.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/achievement_item.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_form_text_field.dart';

// ✅ Achievement Model
class AchievementModel {
  final String title;
  final String description;
  final File? image;
  final DateTime createdAt;

  AchievementModel({
    required this.title,
    required this.description,
    this.image,
    required this.createdAt,
  });
}

class OptionalDetailsSection extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Function({
    // ✅ أضف الـ callback ده
    required String title,
    String? description,
    File? image,
  })?
  onAddAchievement; // ✅ اختياري

  const OptionalDetailsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.onAddAchievement, // ✅ أضف الـ parameter ده
  });

  @override
  State<OptionalDetailsSection> createState() => _OptionalDetailsSectionState();
}

class _OptionalDetailsSectionState extends State<OptionalDetailsSection> {
  final List<AchievementModel> _achievements = [];
  final ImagePicker _imagePicker = ImagePicker();

  // ✅ Get file extension
  String _getFileExtension() {
    if (_selectedAchievementImage == null) return '';
    return _selectedAchievementImage!.path.split('.').last.toUpperCase();
  }

  // ✅ Get file name
  String _getFileName() {
    if (_selectedAchievementImage == null) return '';
    return _selectedAchievementImage!.path.split('/').last;
  }

  // ✅ Controllers للـ Achievement الجديد
  final _achievementTitleController = TextEditingController();
  final _achievementDescriptionController = TextEditingController();
  File? _selectedAchievementImage;

  @override
  void dispose() {
    _achievementTitleController.dispose();
    _achievementDescriptionController.dispose();
    super.dispose();
  }

  // ✅ Pick Image Function
  Future<void> _pickAchievementImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // حواف دائرية من فوق
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4E8C),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4E8C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF1B4E8C),
                      ),
                    ),
                    title: const Text(
                      'Camera',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),

                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4E8C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF1B4E8C),
                      ),
                    ),
                    title: const Text(
                      'Gallery',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final fileSize = await pickedFile.length();

        if (fileSize > 5 * 1024 * 1024) {
          showSnackBar(context, 'File size must be less than 5MB', Colors.red);
          return;
        }
        setState(() {
          _selectedAchievementImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      showSnackBar(context, 'Error picking image: $e', Colors.red);
    }
  }

  // ✅ Add Achievement Function
  void _addAchievement() {
    if (_achievementTitleController.text.isEmpty) {
      showSnackBar(context, 'Please enter achievement title', Colors.red);
      return;
    }

    // ✅ Call Cubit if callback exists
    if (widget.onAddAchievement != null) {
      widget.onAddAchievement!(
        title: _achievementTitleController.text,
        description: _achievementDescriptionController.text,
        image: _selectedAchievementImage,
      );
    }

    // ✅ Add to local list for UI preview
    setState(() {
      _achievements.add(
        AchievementModel(
          title: _achievementTitleController.text,
          description: _achievementDescriptionController.text,
          image: _selectedAchievementImage,
          createdAt: DateTime.now(),
        ),
      );
      _achievementTitleController.clear();
      _achievementDescriptionController.clear();
      _selectedAchievementImage = null;
    });

    showSnackBar(context, 'Achievement added successfully', Colors.green);
  }
  // void _addAchievement() {
  //   if (_achievementTitleController.text.isEmpty) {
  //     showSnackBar(context, 'Please enter achievement title', Colors.red);
  //     return;
  //   }

  //   setState(() {
  //     _achievements.add(
  //       AchievementModel(
  //         title: _achievementTitleController.text,
  //         description: _achievementDescriptionController.text,
  //         image: _selectedAchievementImage,
  //         createdAt: DateTime.now(),
  //       ),
  //     );

  //     // Reset fields
  //     _achievementTitleController.clear();
  //     _achievementDescriptionController.clear();
  //     _selectedAchievementImage = null;
  //   });

  //   showSnackBar(context, 'Achievement added successfully', Colors.green);
  // }

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
                Icons.more_horiz,
                color: const Color(0xFF1B4E8C),
                size: 25.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                "Optional Details",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'OPTIONAL',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ✅ Achievement Title
          CustomFormTextField(
            label: 'Achievement Title',
            hintText: 'e.g. Best Cardiologist Award 2024',
            fieldType: FieldType.achievementTitle,
            controller: _achievementTitleController,
            prefixIcon: Icons.emoji_events,
            maxLength: 200, // ✅ API: max 200 chars
          ),
          SizedBox(height: 16.h),

          // ✅ Achievement Description
          CustomFormTextField(
            label: 'Description',
            hintText: 'Brief description about your achievements and awards...',
            fieldType: FieldType.achievementDescription,
            controller: _achievementDescriptionController,
            prefixIcon: Icons.text_fields_outlined,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000, // ✅ API: max 1000 chars
          ),
          SizedBox(height: 16.h),

          // ✅ Image Upload
          Row(
            children: [
              Icon(Icons.image, color: const Color(0xFF1B4E8C), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Achievement Image',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B4E8C),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (_selectedAchievementImage != null) ...[
            // ✅ File Info Card (نفس ستايل Verification)
            Container(
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
              child: Container(
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
                    SizedBox(height: 12.h),
                    // ✅ File Icon
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 24.sp,
                        color: const Color(0xFF1B4E8C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // ✅ File Name
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
                    // ✅ Remove Button (نفس ستايل Verification)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAchievementImage = null;
                        });
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
            ),
            SizedBox(height: 12.h),
          ] else ...[
            // ✅ Upload Button
            GestureDetector(
              onTap: _pickAchievementImage,
              child: Container(
                alignment: Alignment.center,
                height: 120.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap to upload image',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'JPG, PNG (max: 5MB)',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // ✅ Add Achievement Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addAchievement,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Achievement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4E8C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // ✅ Added Achievements List
          if (_achievements.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: const Color(0xFF1B4E8C),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Added Achievements (${_achievements.length})',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4E8C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _achievements.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return AchievementItem(
                  achievement: achievement,
                  onDelete: () {
                    confirmDelete(context, () {
                      setState(() {
                        _achievements.removeAt(index);
                      });
                      showSnackBar(
                        context,
                        'Achievement deleted',
                        Colors.green,
                      );
                    });
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Helper Methods
  Color _getBackgroundColor() {
    if (_selectedAchievementImage != null) return const Color(0xFFDBEAFE);
    return const Color(0xFFF3F4F6);
  }

  Color _getBorderColor() {
    if (_selectedAchievementImage != null) return const Color(0xFF1B4E8C);
    return const Color(0xFFE5E7EB);
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'custom_form_text_field.dart';

// class OptionalDetailsSection extends StatelessWidget {
//   final TextEditingController titleController;
//   final TextEditingController descriptionController;

//   const OptionalDetailsSection({
//     super.key,
//     required this.titleController,
//     required this.descriptionController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
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
//                 Icons.more_horiz,
//                 color: const Color(0xFF1B4E8C),
//                 size: 25.sp,
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 "Optional Details",
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 'OPTIONAL',
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF9CA3AF),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 24.h),
//           CustomFormTextField(
//             label: 'Title',
//             hintText: 'e.g. Best Cardiologist Award 2024',
//             fieldType: FieldType.text,
//             controller: titleController,
//             prefixIcon: Icons.title,
//           ),
//           SizedBox(height: 16.h),
//           CustomFormTextField(
//             label: 'Description',
//             hintText: 'Brief description about your achievements and awards...',
//             fieldType: FieldType.bio,
//             controller: descriptionController,
//             prefixIcon: Icons.text_fields_outlined,
//             minLines: 3,
//             maxLines: 5,
//           ),
//           SizedBox(height: 16.h),
//           SizedBox(
//             width: double.infinity,
//             child: TextButton.icon(
//               onPressed: () {
//                 // TODO: Add achievement functionality
//               },
//               icon: const Icon(Icons.add_circle, color: Color(0xFF1B4E8C)),
//               label: Text(
//                 'Add Achievement',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF1B4E8C),
//                 ),
//               ),
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 12.h),
//                 backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

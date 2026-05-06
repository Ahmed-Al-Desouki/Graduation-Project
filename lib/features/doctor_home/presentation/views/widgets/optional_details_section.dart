import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/confirm_delete.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/achievement_item.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/existing_achievement_card.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/selected_achievement_image_card.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_form_text_field.dart';

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
  final List<AchievementProfileEntity> existingAchievements;
  final Function({required String title, String? description, File? image})?
  onAddAchievement;

  const OptionalDetailsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.existingAchievements = const [],
    this.onAddAchievement,
  });

  @override
  State<OptionalDetailsSection> createState() => OptionalDetailsSectionState();
}

class OptionalDetailsSectionState extends State<OptionalDetailsSection> {
  final List<AchievementModel> _achievements = [];
  final ImagePicker _imagePicker = ImagePicker();
  final _achievementTitleController = TextEditingController();
  final _achievementDescriptionController = TextEditingController();

  File? _selectedAchievementImage;

  List<AchievementModel> get achievements => _achievements;

  @override
  void dispose() {
    _achievementTitleController.dispose();
    _achievementDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAchievementImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

    if (source == null) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final fileSize = await pickedFile.length();
      if (!mounted) {
        return;
      }

      if (fileSize > 5 * 1024 * 1024) {
        showSnackBar(context, 'File size must be less than 5MB', Colors.red);
        return;
      }

      setState(() {
        _selectedAchievementImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      showSnackBar(context, 'Error picking image: $e', Colors.red);
    }
  }

  void _addAchievement() {
    if (_achievementTitleController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter achievement title', Colors.red);
      return;
    }

    final title = _achievementTitleController.text.trim();
    final description = _achievementDescriptionController.text.trim();
    final image = _selectedAchievementImage;

    setState(() {
      _achievements.add(
        AchievementModel(
          title: title,
          description: description,
          image: image,
          createdAt: DateTime.now(),
        ),
      );
      _achievementTitleController.clear();
      _achievementDescriptionController.clear();
      _selectedAchievementImage = null;
    });

    widget.onAddAchievement?.call(
      title: title,
      description: description.isEmpty ? null : description,
      image: image,
    );

    showSnackBar(context, 'Achievement added to list', Colors.green);
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
                Icons.more_horiz,
                color: const Color(0xFF1B4E8C),
                size: 25.sp,
              ),
              SizedBox(width: 12.w),

              Text(
                'Optional Details',
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

          if (widget.existingAchievements.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              'Existing Achievements',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B4E8C),
              ),
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.existingAchievements.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return ExistingAchievementCard(
                  achievement: widget.existingAchievements[index],
                );
              },
            ),
          ],
          SizedBox(height: 24.h),

          Text(
            'Add New Achievement',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B4E8C),
            ),
          ),
          SizedBox(height: 16.h),

          CustomFormTextField(
            label: 'Achievement Title',
            hintText: 'e.g. Best Cardiologist Award 2024',
            fieldType: FieldType.achievementTitle,
            controller: _achievementTitleController,
            prefixIcon: Icons.emoji_events,
            maxLength: 200,
          ),
          SizedBox(height: 16.h),

          CustomFormTextField(
            label: 'Description',
            hintText: 'Brief description about your achievements and awards...',
            fieldType: FieldType.achievementDescription,
            controller: _achievementDescriptionController,
            prefixIcon: Icons.text_fields_outlined,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
          ),
          SizedBox(height: 16.h),

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

          if (_selectedAchievementImage != null)
            SelectedAchievementImageCard(
              image: _selectedAchievementImage!,
              onRemove:
                  () => setState(() {
                    _selectedAchievementImage = null;
                  }),
            )
          else
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
          SizedBox(height: 16.h),

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

          if (_achievements.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: const Color(0xFF1B4E8C),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'New Achievements (${_achievements.length})',
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
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:image_picker/image_picker.dart';

class EditAchievementSheet extends StatefulWidget {
  final AchievementProfileEntity achievement;
  const EditAchievementSheet({super.key, required this.achievement});

  @override
  State<EditAchievementSheet> createState() => _EditAchievementSheetState();
}

class _EditAchievementSheetState extends State<EditAchievementSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  File? newImage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.achievement.title);
    descriptionController = TextEditingController(
      text: widget.achievement.description,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => newImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Achievement",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),

              CustomFormTextField(
                label: 'Achievement Title',
                hintText: 'e.g. Best Cardiologist Award 2024',
                fieldType: FieldType.achievementTitle,
                controller: titleController,
                prefixIcon: Icons.emoji_events,
                maxLength: 200,
              ),
              SizedBox(height: 10.h),
              CustomFormTextField(
                label: 'Description',
                hintText:
                    'Brief description about your achievements and awards...',
                fieldType: FieldType.achievementDescription,
                controller: descriptionController,
                prefixIcon: Icons.text_fields_outlined,
                maxLength: 1000,
              ),
              SizedBox(height: 10.h),

              // Image Preview / Upload
              if (newImage != null)
                Image.file(newImage!, height: 120.h)
              else if (widget.achievement.imageUrl != null)
                Image.network(widget.achievement.imageUrl!, height: 120.h),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Color(0xFF754EA6)),
                label: const Text(
                  'Change Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF754EA6),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF754EA6),
                  side: const BorderSide(color: Color(0xFF754EA6), width: 1.5),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 25.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF754EA6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  // onPressed: () {
                  //   final cubit = context.read<DoctorRealProfileCubit>();
                  //   Navigator.of(context).pop();

                  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
                  //     await cubit.updateAchievement(
                  //       achievementId: widget.achievement.achievementId!,
                  //       title: titleController.text,
                  //       description: descriptionController.text,
                  //       image: newImage,
                  //     );

                  //     await cubit.getDoctorProfile();
                  //   });
                  // },
                  onPressed: () async {
                    final cubit = context.read<DoctorRealProfileCubit>();

                    // ✅ أول حاجة: عمل التعديل
                    await cubit.updateAchievement(
                      achievementId: widget.achievement.achievementId!,
                      title: titleController.text,
                      description: descriptionController.text,
                      image: newImage,
                    );
                    // ✅ في الآخر: اقفل الـ sheet
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

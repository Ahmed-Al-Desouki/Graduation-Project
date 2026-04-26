import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_basic_info_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/rating_row_for_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/stat_item_for_header.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorProfileEntity profile;
  const DoctorProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorRealProfileCubit, DoctorRealProfileState>(
      listener: (context, state) {
        log('📊 State changed: $state');
        if (state is UpdateProfileImageLoading) {
          log('⏳ Uploading...');
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is UpdateProfileImageSuccess) {
          log('✅ Upload success!');
          Navigator.pop(context);
          showSnackBar(
            context,
            'Profile image updated successfully',
            Color(0xFF10B981),
          );
        } else if (state is UpdateProfileImageFailure) {
          log('❌ Upload failed: ${state.errorMessage}');
          Navigator.pop(context);
          showSnackBar(context, state.errorMessage, Colors.red);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showEditBasicInfoSheet(context, profile);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.grey.shade400, size: 17),
                      SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(profile.profileImageUrl ?? ''),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showEditProfileImageSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF1B4E8C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              profile.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (profile.dateOfBirth != null)
              Text(
                profile.dateOfBirth!.toLocal().toString().split(' ')[0],
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            if (profile.phoneNumber != null)
              Text(
                profile.phoneNumber!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            Text(
              profile.email,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '${profile.specialization} • ${profile.yearsOfExperience} years experience',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            RatingRowForHeader(rating: profile.averageRating),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatItemForHeader(value: "2.8K+", label: "Patients"),
                StatItemForHeader(value: "98%", label: "Success Rate"),
                StatItemForHeader(value: "24/7", label: "Available"),
              ],
            ),
            const SizedBox(height: 15),
            if (profile.nationalId != null)
              Text(
                "National ID : ${profile.nationalId}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditBasicInfoSheet(
    BuildContext context,
    DoctorProfileEntity profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<DoctorRealProfileCubit>(),
            child: EditBasicInfoSheet(profile: profile),
          ),
    );
  }

  void _showEditProfileImageSheet(BuildContext context) {
    final cubit = context.read<DoctorRealProfileCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => BlocProvider.value(
            value: cubit,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4E8C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF1B4E8C),
                    ),
                    title: const Text('Take Photo'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(cubit, ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF1B4E8C),
                    ),
                    title: const Text('Choose from Gallery'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(cubit, ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(
    DoctorRealProfileCubit cubit,
    ImageSource source,
  ) async {
    log('📸 Starting image picker...');

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    log('📸 Picked file: ${pickedFile?.path}');

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      log('📸 File size: ${fileSize / 1024 / 1024} MB');
      await cubit.updateProfileImage(file);
      log('📸 Update completed');
    } else {
      log('❌ No image selected');
    }
  }
}

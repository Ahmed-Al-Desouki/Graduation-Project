import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/edit_patient_basic_info_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PatientProfileHeader extends StatelessWidget {
  final PatientAccountProfileEntity profile;

  const PatientProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profileImageUrl?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
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
                onPressed: () => _showEditBasicInfoSheet(context),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.grey.shade400, size: 17),
                    const SizedBox(width: 5),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child:
                    imageUrl.isEmpty
                        ? const Icon(
                          Icons.person,
                          size: 55,
                          color: Colors.white,
                        )
                        : null,
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
            _fallbackText(profile.fullName, fallback: 'Unknown'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Birth Date : ${_formatDate(profile.dateOfBirth)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            'Phone Number : ${_fallbackText(profile.phoneNumber, fallback: 'N/A')}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            'Email : ${_fallbackText(profile.email, fallback: 'N/A')}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _fallbackText(String? value, {required String fallback}) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }

  void _showEditBasicInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder:
          (_) => BlocProvider.value(
            value: context.read<PatientAccountProfileCubit>(),
            child: EditPatientBasicInfoSheet(profile: profile),
          ),
    );
  }

  void _showEditProfileImageSheet(BuildContext context) {
    final cubit = context.read<PatientAccountProfileCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => Padding(
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4E8C),
                  ),
                ),
                const SizedBox(height: 20),
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
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(cubit, ImageSource.camera);
                  },
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
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(cubit, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(
    PatientAccountProfileCubit cubit,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    await cubit.updateProfileImage(File(pickedFile.path));
  }
}

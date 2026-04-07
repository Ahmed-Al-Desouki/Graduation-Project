import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'profile_view_mode.dart';
import 'profile_edit_form.dart';

class HealthProfileSection extends StatefulWidget {
  final PatientProfileModel profile;
  final bool isDoctorView;
  final Function(Map<String, dynamic>) onSave;

  const HealthProfileSection({
    super.key,
    required this.profile,
    required this.isDoctorView,
    required this.onSave,
  });

  @override
  State<HealthProfileSection> createState() => _HealthProfileSectionState();
}

class _HealthProfileSectionState extends State<HealthProfileSection> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeadersFieldInRegistration(
                imagePath: Assets.imagesUserRegular,
                title: "Personal Information",
              ),
              if (!widget.isDoctorView)
                TextButton.icon(
                  onPressed: () => setState(() => isEditMode = !isEditMode),
                  icon: Icon(
                    isEditMode ? Icons.close : Icons.edit,
                    size: 18,
                    color: isEditMode ? Colors.red : const Color(0xff4a90e2),
                  ),
                  label: Text(
                    isEditMode ? "Cancel" : "Edit",
                    style: TextStyle(
                      color: isEditMode ? Colors.red : const Color(0xff4a90e2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 30),
          if (!isEditMode) ...[
            Text(
              widget.profile.fullName,
              style: AppStyles.styleSemiBold18Dark.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 20),
          ],

          AnimatedCrossFade(
            firstChild: ProfileViewMode(profile: widget.profile),
            secondChild: ProfileEditForm(
              currentProfile: widget.profile,
              onSave: (updateMap) {
                widget.onSave(updateMap);
                setState(() => isEditMode = false);
              },
            ),
            crossFadeState:
                isEditMode
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

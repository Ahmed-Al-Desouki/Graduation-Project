import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';

class PersonalInfoSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController dateOfBirthController;
  final VoidCallback onDateSelected;

  const PersonalInfoSection({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneNumberController,
    required this.dateOfBirthController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
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
                Icon(Icons.person, color: const Color(0xFF1B4E8C), size: 25.sp),
                SizedBox(width: 12.w),
                Text(
                  "Personal Info",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            CustomFormTextField(
              label: 'Full Name',
              hintText: 'Full Name',
              fieldType: FieldType.name,
              controller: fullNameController,
              prefixIcon: Icons.person,
              maxLength: 100,
            ),
            SizedBox(height: 16.h),

            Row(
              children: [
                Expanded(
                  child: CustomFormTextField(
                    label: 'Phone Number',
                    hintText: '+1 (555) 000-0',
                    fieldType: FieldType.phone,
                    controller: phoneNumberController,
                    prefixIcon: Icons.phone,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomFormTextField(
                    label: 'Date of Birth',
                    hintText: 'mm/dd/yyyy',
                    fieldType: FieldType.date,
                    controller: dateOfBirthController,
                    prefixIcon: Icons.calendar_month,
                    readOnly: true,
                    onTap: onDateSelected,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

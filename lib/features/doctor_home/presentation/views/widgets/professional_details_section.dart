import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_form_text_field.dart';

class ProfessionalDetailsSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController experienceController;
  final TextEditingController feeController;
  final TextEditingController nationalIdController;
  final TextEditingController
  specializationController; // ✅ تغير من String? لـ Controller
  final Function(String)?
  onSpecializationChanged; // ✅ اختياري لو عايز تتبع التغيير

  const ProfessionalDetailsSection({
    super.key,
    required this.formKey,
    required this.experienceController,
    required this.feeController,
    required this.nationalIdController,
    required this.specializationController,
    this.onSpecializationChanged,
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
              color: Colors.black.withOpacity(0.05),
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
                  Icons.business_center_sharp,
                  color: const Color(0xFF1B4E8C),
                  size: 25.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  "Professional Details",
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
              label: 'Specialization',
              hintText: 'e.g. Cardiologist',
              fieldType: FieldType.text,
              controller: specializationController,
              prefixIcon: Icons.medical_services,
              onChanged: onSpecializationChanged,
              maxLength: 100,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomFormTextField(
                    label: 'Experience (Years)',
                    hintText: 'e.g. 10',
                    fieldType: FieldType.number,
                    controller: experienceController,
                    prefixIcon: Icons.work,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomFormTextField(
                    label: 'Fee (\$)',
                    hintText: 'e.g. 150',
                    fieldType: FieldType.number,
                    controller: feeController,
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomFormTextField(
              label: 'National ID / License Number',
              hintText: 'Enter ID number',
              fieldType: FieldType.license,
              controller: nationalIdController,
              prefixIcon: Icons.badge,
              maxLength: 20,
            ),
          ],
        ),
      ),
    );
  }
}

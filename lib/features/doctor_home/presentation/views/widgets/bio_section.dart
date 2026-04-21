import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_form_text_field.dart';

class BioSection extends StatefulWidget {
  final TextEditingController bioController;

  const BioSection({super.key, required this.bioController});

  @override
  State<BioSection> createState() => _BioSectionState();
}

class _BioSectionState extends State<BioSection> {
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
              Icon(Icons.article, color: const Color(0xFF1B4E8C), size: 25.sp),
              SizedBox(width: 12.w),
              Text(
                "Bio",
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
            'Tell patients about you, your practice, expertise, and what makes you unique.',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          CustomFormTextField(
            hintText: 'Brief description about your practice and expertise...',
            fieldType: FieldType.bio,
            controller: widget.bioController,
            prefixIcon: Icons.text_fields_outlined,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_form_text_field.dart';

class LocationSection extends StatelessWidget {
  final TextEditingController clinicNameController;
  final TextEditingController addressController;
  final VoidCallback onPickLocation;
  final String? selectedLocation;

  const LocationSection({
    super.key,
    required this.clinicNameController,
    required this.addressController,
    required this.onPickLocation,
    this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Icons.location_on,
                color: const Color(0xFF1B4E8C),
                size: 25.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                "Location",
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
            label: 'Clinic Name',
            hintText: 'e.g. Wellora Medical Center',
            fieldType: FieldType.text,
            controller: clinicNameController,
            prefixIcon: Icons.location_city,
            maxLength: 200,
          ),
          SizedBox(height: 16.h),

          CustomFormTextField(
            label: 'Clinic Address',
            hintText: 'Building number, street name, floor',
            fieldType: FieldType.text,
            controller: addressController,
            prefixIcon: Icons.home,
            minLines: 1,
            maxLines: 3,
            maxLength: 500,
          ),
          SizedBox(height: 16.h),

          // Pick from Map Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPickLocation,
              icon: const Icon(Icons.map, color: Color(0xFF3B82F6)),
              label: Text(
                selectedLocation ?? 'Pick Location from Map',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Location Info
          if (selectedLocation != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF1B4E8C),
                    size: 20,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      selectedLocation!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B4E8C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'Patients will use this address to find your clinic',
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

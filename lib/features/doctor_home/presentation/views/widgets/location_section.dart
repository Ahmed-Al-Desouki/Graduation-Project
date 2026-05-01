import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_form_text_field.dart';

class LocationSection extends StatelessWidget {
  final TextEditingController clinicNameController;
  final TextEditingController addressController;
  final VoidCallback onPickLocation;
  final String? selectedLocation;
  final double? latitude;
  final double? longitude;
  final Function(double?, double?)? onCoordinatesSelected;

  const LocationSection({
    super.key,
    required this.clinicNameController,
    required this.addressController,
    required this.onPickLocation,
    this.selectedLocation,
    this.latitude,
    this.longitude,
    this.onCoordinatesSelected,
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

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPickLocation,
              icon: Row(
                children: [
                  SizedBox(width: 10.w),
                  Icon(Icons.map, color: Color(0xFF3B82F6)),
                ],
              ),
              label: Text(
                selectedLocation ?? 'Pick Location',
                textAlign: TextAlign.center,
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

          if (selectedLocation != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1B4E8C),
                        size: 20,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          selectedLocation!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1B4E8C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (latitude != null && longitude != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Coordinates: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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

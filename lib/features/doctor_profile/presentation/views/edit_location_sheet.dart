import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/map_picker_bottom_sheet.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';

class EditLocationSheet extends StatefulWidget {
  final DoctorProfileEntity profile;
  const EditLocationSheet({super.key, required this.profile});

  @override
  State<EditLocationSheet> createState() => _EditLocationSheetState();
}

class _EditLocationSheetState extends State<EditLocationSheet> {
  late TextEditingController clinicNameController;
  late TextEditingController addressController;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    clinicNameController = TextEditingController(
      text: widget.profile.hospitalName,
    );
    addressController = TextEditingController(
      text: widget.profile.clinicAddress,
    );
    latitude = widget.profile.clinicLatitude;
    longitude = widget.profile.clinicLongitude;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Location",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
              maxLines: 2,
            ),
            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder:
                        (_) => MapPickerBottomSheet(
                          onLocationSelected: (location, lat, lng) {
                            setState(() {
                              addressController.text = location;
                              latitude = lat;
                              longitude = lng;
                            });
                          },
                        ),
                  );
                },
                icon: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Icon(Icons.map, color: Color(0xFF3B82F6)),
                  ],
                ),
                label: Text(
                  'Pick Location',
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
            SizedBox(height: 32.h),

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
                onPressed: () {
                  final cubit = context.read<DoctorRealProfileCubit>();
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await cubit.updateLocation(
                      clinicAddress: addressController.text,
                      hospitalName: clinicNameController.text,
                      latitude: latitude,
                      longitude: longitude,
                    );

                    await cubit.getDoctorProfile();
                  });
                },
                child: const Text(
                  "Save Location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

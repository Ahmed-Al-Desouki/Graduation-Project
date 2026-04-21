import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';

class EditBasicInfoSheet extends StatefulWidget {
  final DoctorProfileEntity profile;
  const EditBasicInfoSheet({super.key, required this.profile});

  @override
  State<EditBasicInfoSheet> createState() => _EditBasicInfoSheetState();
}

class _EditBasicInfoSheetState extends State<EditBasicInfoSheet> {
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController specializationController;
  late TextEditingController nationalIdController;
  late TextEditingController experienceController;

  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.profile.fullName);
    phoneController = TextEditingController(text: widget.profile.phoneNumber);
    specializationController = TextEditingController(
      text: widget.profile.specialization,
    );
    nationalIdController = TextEditingController(
      text: widget.profile.nationalId,
    );
    experienceController = TextEditingController(
      text: widget.profile.yearsOfExperience?.toString() ?? '',
    );
    selectedDateOfBirth = widget.profile.dateOfBirth;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Basic Information",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
                      controller: phoneController,
                      prefixIcon: Icons.phone,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomFormTextField(
                      label: 'Date of Birth',
                      hintText: 'mm/dd/yyyy',
                      fieldType: FieldType.date,
                      controller: TextEditingController(
                        text:
                            selectedDateOfBirth != null
                                ? "${selectedDateOfBirth!.day.toString().padLeft(2, '0')}/${selectedDateOfBirth!.month.toString().padLeft(2, '0')}/${selectedDateOfBirth!.year}"
                                : '',
                      ),
                      prefixIcon: Icons.calendar_month,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: CustomFormTextField(
                      label: 'Specialization',
                      hintText: 'e.g. Cardiologist',
                      fieldType: FieldType.text,
                      controller: specializationController,
                      prefixIcon: Icons.medical_services,
                      maxLength: 100,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomFormTextField(
                      label: 'National ID',
                      hintText: 'Enter ID number',
                      fieldType: FieldType.license,
                      controller: nationalIdController,
                      prefixIcon: Icons.badge,
                      maxLength: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              CustomFormTextField(
                label: 'Experience (Years)',
                hintText: 'e.g. 10',
                fieldType: FieldType.number,
                controller: experienceController,
                prefixIcon: Icons.work,
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
                      await cubit.updateBasicInfo(
                        fullName: fullNameController.text,
                        phoneNumber: phoneController.text,
                        dateOfBirth: selectedDateOfBirth,
                        specialization: specializationController.text,
                        yearsOfExperience: int.tryParse(
                          experienceController.text,
                        ),
                        nationalId: nationalIdController.text,
                      );

                      await cubit.getDoctorProfile();
                    });
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

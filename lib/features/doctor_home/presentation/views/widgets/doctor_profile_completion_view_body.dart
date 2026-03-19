import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/bio_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/location_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/map_picker_bottom_sheet.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/optional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/personal_info_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/professional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_button.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_header_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_progress_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/verification_section.dart';

class DoctorProfileCompletionViewBody extends StatefulWidget {
  const DoctorProfileCompletionViewBody({super.key});

  @override
  State<DoctorProfileCompletionViewBody> createState() =>
      _DoctorProfileCompletionViewBodyState();
}

class _DoctorProfileCompletionViewBodyState
    extends State<DoctorProfileCompletionViewBody> {
  // ✅ Form Keys
  final _personalInfoKey = GlobalKey<FormState>();
  final _professionalInfoKey = GlobalKey<FormState>();

  // ✅ Controllers
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController =
      TextEditingController(); // لكتابة وصف لانجاز معين
  final _bioController = TextEditingController(); // ✅ للوصف
  final _clinicNameController = TextEditingController(); // ✅ للعيادة
  final _addressController = TextEditingController(); // ✅ للعنوان

  // ✅ Selected Values
  String? _selectedLocation;
  DateTime? _selectedDateOfBirth;

  // ✅ Upload States
  bool _medicalLicenseUploaded = false;
  bool _graduationCertUploaded = false;
  bool _nationalIdUploaded = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _nationalIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _bioController.dispose();
    _clinicNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ✅ أضف الدالة دي هنا (قبل الـ build method)
  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => MapPickerBottomSheet(
            onLocationSelected: (location) {
              if (mounted) {
                setState(() {
                  _selectedLocation = location;
                });
              }
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeaderSection(),
          SizedBox(height: 24.h),
          ProfileProgressSection(currentStep: 1, totalSteps: 2),
          SizedBox(height: 24.h),
          PersonalInfoSection(
            formKey: _personalInfoKey,
            fullNameController: _fullNameController,
            phoneNumberController: _phoneNumberController,
            dateOfBirthController: _dateOfBirthController,
            onDateSelected: _selectDateOfBirth,
          ),
          SizedBox(height: 20.h),
          ProfessionalDetailsSection(
            formKey: _professionalInfoKey,
            experienceController: _experienceController,
            feeController: _feeController,
            nationalIdController: _nationalIdController,
            specializationController: _specializationController,
            onSpecializationChanged: (value) {
              // ✅ لو عايز تتبع التغيير (اختياري)
              print('Specialization changed to: $value');
            },
          ),
          SizedBox(height: 20.h),
          VerificationSection(
            medicalLicenseUploaded: _medicalLicenseUploaded,
            graduationCertUploaded: _graduationCertUploaded,
            nationalIdUploaded: _nationalIdUploaded,
          ),
          SizedBox(height: 20.h),
          BioSection(bioController: _bioController),
          SizedBox(height: 20.h),
          LocationSection(
            clinicNameController: _clinicNameController,
            addressController: _addressController,
            onPickLocation: _showMapPicker,
            selectedLocation: _selectedLocation,
          ),
          SizedBox(height: 20.h),
          OptionalDetailsSection(
            titleController: _titleController,
            descriptionController: _descriptionController,
          ),
          SizedBox(height: 20.h),
          ProfileCompletionButton(onPressed: _validateAndSubmit),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        // ✅ احفظ الـ DateTime كامل (هنحوله لـ ISO 8601 لما نبعته للـ API)
        _dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Future<void> _selectDateOfBirth() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime(1990),
  //     firstDate: DateTime(1950),
  //     lastDate: DateTime.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: Color(0xFF3B82F6),
  //             onPrimary: Colors.white,
  //             surface: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       _selectedDateOfBirth = picked;
  //       _dateOfBirthController.text =
  //           "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
  //     });
  //   }
  // }

  void _validateAndSubmit() {
    if (_personalInfoKey.currentState!.validate() &&
        _professionalInfoKey.currentState!.validate()) {
      // ✅ هنا هتجمع كل البيانات عشان تبعتها للـ API
      final doctorData = {
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'dateOfBirth': _selectedDateOfBirth?.toUtc().toIso8601String(),
        'specialization': _specializationController.text,
        'experience': _experienceController.text,
        'fee': _feeController.text,
        'nationalId': _nationalIdController.text,
        'title': _titleController.text,
        'bio': _bioController.text,
        'description': _descriptionController.text,
        'clinicName': _clinicNameController.text,
        'address': _addressController.text,
        'location': _selectedLocation,
      };

      print('📝 Doctor Data: $doctorData');

      // TODO: Submit data to API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile completed successfully!"),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate to home or next step
      // Navigator.pop(context);
    }
  }
}

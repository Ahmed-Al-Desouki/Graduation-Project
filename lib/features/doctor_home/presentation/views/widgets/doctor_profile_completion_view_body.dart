import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/verification_document_entity.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_state.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/bio_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/location_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/map_picker_bottom_sheet.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/optional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/personal_info_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/professional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_button.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_header_section.dart';
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
  final _descriptionController = TextEditingController();
  final _bioController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();

  // ✅ Selected Values
  String? _selectedLocation;
  DateTime? _selectedDateOfBirth;
  // ✅ أضف الـ Coordinates variables
  double? _selectedLatitude;
  double? _selectedLongitude;

  // ✅ Upload States (للـ UI فقط - الـ Logic في الـ Cubit)
  bool _medicalLicenseUploaded = false;
  bool _graduationCertUploaded = false;
  bool _nationalIdUploaded = false;
  File? _medicalLicenseFile;
  File? _graduationCertFile;
  File? _nationalIdFile;

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

  // ✅ Map Picker (محدث)
  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => MapPickerBottomSheet(
            onLocationSelected: (location, lat, lng) {
              // ✅ عدّل الـ callback
              if (mounted) {
                setState(() {
                  _selectedLocation = location;
                  _selectedLatitude = lat;
                  _selectedLongitude = lng;
                });
                // ✅ اطبع عشان تتأكد
                print('📍 Location: $location');
                print('📍 Latitude: $lat');
                print('📍 Longitude: $lng');
              }
              Navigator.pop(context);
            },
            addressController: _addressController,
          ),
    );
  }

  // ✅ Verification Document Upload
  Future<void> _uploadVerificationDocument(String type) async {
    File? file;
    DocumentType docType;

    switch (type) {
      case 'medical':
        file = _medicalLicenseFile;
        docType = DocumentType.license;
        break;
      case 'graduation':
        file = _graduationCertFile;
        docType = DocumentType.graduationCertificate;
        break;
      case 'national':
        file = _nationalIdFile;
        docType = DocumentType.nationalId;
        break;
      default:
        return;
    }

    if (file == null) return;

    // ✅ Call Cubit method
    await context.read<DoctorProfileCubit>().uploadVerificationDocument(
      documentType: docType,
      file: file,
    );
  }

  // ✅ Achievement Upload (من الـ OptionalDetailsSection)
  Future<void> _addAchievement({
    required String title,
    String? description,
    File? image,
  }) async {
    await context.read<DoctorProfileCubit>().addAchievement(
      title: title,
      description: description,
      image: image,
    );
  }

  // ✅ Main Submit Function
  Future<void> _validateAndSubmit() async {
    // ✅ 1. لو الـ validation فشل، ارجع فوراً
    if (!_personalInfoKey.currentState!.validate() ||
        !_professionalInfoKey.currentState!.validate()) {
      return; // ✅ وقف هنا
    }

  print('   └─ Clinic Address: ${_addressController.text}');
  print('   └─ Hospital Name: ${_clinicNameController.text}');
  print('   └─ Latitude: $_selectedLatitude');
  print('   └─ Longitude: $_selectedLongitude');

    // ✅ 2. لو الـ validation نجح، جهّز البيانات
    final cubit = context.read<DoctorProfileCubit>();

    // ✅ 3. Complete Profile
    await cubit.completeProfile(
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      dateOfBirth: _selectedDateOfBirth!, // ⚠️ شوف النقطة 3 تحت
      specialization: _specializationController.text,
      yearsOfExperience:
          int.tryParse(_experienceController.text) ?? 0, // ✅ استخدم tryParse
      consultationFee:
          double.tryParse(_feeController.text) ?? 0.0, // ✅ استخدم tryParse
      nationalId: _nationalIdController.text,
      bio: _bioController.text,
    );

    // ✅ 4. Upload Verification Documents
    if (_medicalLicenseFile != null) {
      await _uploadVerificationDocument('medical');
    }
    if (_graduationCertFile != null) {
      await _uploadVerificationDocument('graduation');
    }
    if (_nationalIdFile != null) {
      await _uploadVerificationDocument('national');
    }

    // ✅ 5. Update Location
    await cubit.updateLocation(
      clinicAddress: _selectedLocation ?? 
      (_addressController.text.isNotEmpty ? _addressController.text : null),
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      hospitalName: _clinicNameController.text.isNotEmpty 
      ? _clinicNameController.text 
      : null,
    );
    // await cubit.updateLocation(
    //   clinicAddress: _addressController.text,
    //   latitude: _selectedLatitude,
    //   longitude: _selectedLongitude,
    //   hospitalName: _clinicNameController.text,
    // );

    // ✅ 6. Navigate to Loading Screen
    if (mounted) {
      cubit.startAdminReviewPolling();
      AppRouter.router.push(AppRouter.kProfileCompletionLoading);
    }
  }
  // Future<void> _validateAndSubmit() async {
  //   if (!_personalInfoKey.currentState!.validate() ||
  //       !_professionalInfoKey.currentState!.validate()) {
  //     // ✅ جهّز بيانات اللوكيشن للـ API
  //     final locationData = {
  //       if (_addressController.text.isNotEmpty)
  //         'clinicAddress': _addressController.text,
  //       if (_clinicNameController.text.isNotEmpty)
  //         'hospitalName': _clinicNameController.text,
  //       if (_selectedLatitude != null)
  //         'clinicLatitude': _selectedLatitude,
  //       if (_selectedLongitude != null)
  //         'clinicLongitude': _selectedLongitude,
  //     };

  //     final doctorData = {
  //       'fullName': _fullNameController.text,
  //       'phoneNumber': _phoneNumberController.text,
  //       'dateOfBirth': _selectedDateOfBirth?.toUtc().toIso8601String(),
  //       'specialization': _specializationController.text,
  //       'yearsOfExperience': int.tryParse(_experienceController.text) ?? 0,
  //       'consultationFee': double.tryParse(_feeController.text) ?? 0.0,
  //       'nationalId': _nationalIdController.text,
  //       'bio': _bioController.text,
  //       // ✅ أضف اللوكيشن
  //       'location': locationData,
  //     };

  //     print('📝 Doctor Data: $doctorData');
  //     // TODO: Submit to API
  //   }

  //   final cubit = context.read<DoctorProfileCubit>();

  //   // ✅ 1. Complete Profile (Required fields)
  //   await cubit.completeProfile(
  //     fullName: _fullNameController.text,
  //     phoneNumber: _phoneNumberController.text,
  //     dateOfBirth: _selectedDateOfBirth!,
  //     specialization: _specializationController.text,
  //     yearsOfExperience: int.parse(_experienceController.text),
  //     consultationFee: double.parse(_feeController.text),
  //     nationalId: _nationalIdController.text,
  //     bio: _bioController.text,  // ✅ هيضاف من الباك بعدين
  //   );

  //   // ✅ 2. Upload Verification Documents (لو موجودة)
  //   if (_medicalLicenseFile != null) {
  //     await _uploadVerificationDocument('medical');
  //   }
  //   if (_graduationCertFile != null) {
  //     await _uploadVerificationDocument('graduation');
  //   }
  //   if (_nationalIdFile != null) {
  //     await _uploadVerificationDocument('national');
  //   }

  //   // ✅ 3. Update Location (لو موجود)
  //   if (_clinicNameController.text.isNotEmpty ||
  //       _addressController.text.isNotEmpty) {
  //     await cubit.updateLocation(
  //       clinicAddress: _addressController.text,
  //       hospitalName: _clinicNameController.text,
  //     );
  //   }

  //   // ✅ 4. Add Achievements (من الـ OptionalDetailsSection)
  //   // Loop through achievements and call _addAchievement for each

  //   // ✅ 5. Navigate to Loading Screen
  //   if (mounted) {
  //     // ✅ Start polling for admin review
  //     cubit.startAdminReviewPolling();
  //     AppRouter.router.push(AppRouter.kProfileCompletionLoading);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorProfileCubit, DoctorProfileState>(
      listener: (context, state) {
        // ✅ Handle errors
        if (state is CompleteProfileFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
        if (state is VerificationDocumentFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
        if (state is UpdateLocationFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
        if (state is AddAchievementFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeaderSection(),
            // SizedBox(height: 24.h),
            // const ProfileProgressSection(currentStep: 1, totalSteps: 2),
            SizedBox(height: 15.h),

            // ✅ Personal Info
            PersonalInfoSection(
              formKey: _personalInfoKey,
              fullNameController: _fullNameController,
              phoneNumberController: _phoneNumberController,
              dateOfBirthController: _dateOfBirthController,
              onDateSelected: _selectDateOfBirth,
            ),
            SizedBox(height: 20.h),

            // ✅ Professional Details
            ProfessionalDetailsSection(
              formKey: _professionalInfoKey,
              experienceController: _experienceController,
              feeController: _feeController,
              nationalIdController: _nationalIdController,
              specializationController: _specializationController,
              onSpecializationChanged: (value) {
                print('Specialization changed to: $value');
              },
            ),
            SizedBox(height: 20.h),

            // ✅ Verification Documents
            VerificationSection(
              medicalLicenseUploaded: _medicalLicenseUploaded,
              graduationCertUploaded: _graduationCertUploaded,
              nationalIdUploaded: _nationalIdUploaded,
              onFileSelected: (type, file) {
                // ✅ Handle file selection
                setState(() {
                  switch (type) {
                    case 'medical':
                      _medicalLicenseFile = file;
                      break;
                    case 'graduation':
                      _graduationCertFile = file;
                      break;
                    case 'national':
                      _nationalIdFile = file;
                      break;
                  }
                });
              },
              onUpload: _uploadVerificationDocument,
            ),
            SizedBox(height: 20.h),

            // ✅ Bio
            BioSection(bioController: _bioController),
            SizedBox(height: 20.h),

            // ✅ Location
            LocationSection(
              clinicNameController: _clinicNameController,
              addressController: _addressController,
              onPickLocation: _showMapPicker,
              selectedLocation: _selectedLocation,
            ),
            SizedBox(height: 20.h),

            // ✅ Optional Details (Achievements)
            OptionalDetailsSection(
              titleController: _titleController,
              descriptionController: _descriptionController,
              onAddAchievement: _addAchievement, // ✅ أضف الـ callback ده
            ),
            SizedBox(height: 20.h),

            // ✅ Submit Button
            ProfileCompletionButton(onPressed: _validateAndSubmit),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ✅ Date Picker
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }
}

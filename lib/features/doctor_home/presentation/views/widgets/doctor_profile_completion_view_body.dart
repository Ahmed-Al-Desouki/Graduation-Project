import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/achievement_entity.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/verification_document_entity.dart'
    as onboarding_document;
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_state.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/bio_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/location_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/map_picker_bottom_sheet.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/optional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/personal_info_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_button.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_header_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/professional_details_section.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/verification_section.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart'
    as profile_document;

class DoctorProfileCompletionViewBody extends StatefulWidget {
  final DoctorProfileEntity? initialProfile;

  const DoctorProfileCompletionViewBody({super.key, this.initialProfile});

  @override
  State<DoctorProfileCompletionViewBody> createState() =>
      _DoctorProfileCompletionViewBodyState();
}

class _DoctorProfileCompletionViewBodyState
    extends State<DoctorProfileCompletionViewBody> {
  final _personalInfoKey = GlobalKey<FormState>();
  final _professionalInfoKey = GlobalKey<FormState>();
  final _verificationSectionKey = GlobalKey<VerificationSectionState>();
  final _optionalDetailsKey = GlobalKey<OptionalDetailsSectionState>();

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

  String? _selectedLocation;
  DateTime? _selectedDateOfBirth;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile(widget.initialProfile);
  }

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

  void _prefillFromProfile(DoctorProfileEntity? profile) {
    if (profile == null) {
      return;
    }

    _fullNameController.text = profile.fullName;
    _phoneNumberController.text = profile.phoneNumber ?? '';
    _selectedDateOfBirth = profile.dateOfBirth;
    if (_selectedDateOfBirth != null) {
      _dateOfBirthController.text = _formatDate(_selectedDateOfBirth!);
    }
    _specializationController.text = profile.specialization;
    _experienceController.text = profile.yearsOfExperience.toString();
    _feeController.text = _formatFee(profile.consultationFee);
    _nationalIdController.text = profile.nationalId ?? '';
    _bioController.text = profile.bio ?? '';
    _clinicNameController.text = profile.hospitalName ?? '';
    _addressController.text = profile.clinicAddress ?? '';
    _selectedLocation = profile.clinicAddress;
    _selectedLatitude = profile.clinicLatitude;
    _selectedLongitude = profile.clinicLongitude;
  }

  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => MapPickerBottomSheet(
            onLocationSelected: (location, lat, lng) {
              if (!mounted) {
                return;
              }

              setState(() {
                _selectedLocation = location;
                _selectedLatitude = lat;
                _selectedLongitude = lng;
                _addressController.text = location;
              });

              Navigator.pop(context);
            },
            addressController: _addressController,
          ),
    );
  }

  Future<void> _validateAndSubmit() async {
    if (!_personalInfoKey.currentState!.validate() ||
        !_professionalInfoKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      showSnackBar(context, 'Please select your date of birth.', Colors.red);
      return;
    }

    if (!_validateRequiredDocuments()) {
      return;
    }

    final verificationFiles =
        _verificationSectionKey.currentState?.selectedFiles ??
        const <onboarding_document.DocumentType, File?>{};

    final achievements =
        _optionalDetailsKey.currentState?.achievements
            .map(
              (achievement) => AchievementEntity(
                title: achievement.title,
                description: achievement.description,
                image: achievement.image,
                createdAt: achievement.createdAt,
              ),
            )
            .toList() ??
        const <AchievementEntity>[];

    await context.read<DoctorProfileCubit>().submitProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      dateOfBirth: _selectedDateOfBirth!,
      specialization: _specializationController.text.trim(),
      yearsOfExperience: int.tryParse(_experienceController.text.trim()) ?? 0,
      consultationFee: double.tryParse(_feeController.text.trim()) ?? 0,
      nationalId: _nationalIdController.text.trim(),
      bio: _bioController.text.trim(),
      clinicAddress:
          _resolvedClinicAddress.isEmpty ? null : _resolvedClinicAddress,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      hospitalName:
          _clinicNameController.text.trim().isEmpty
              ? null
              : _clinicNameController.text.trim(),
      verificationFiles: verificationFiles,
      achievements: achievements,
      existingProfile: widget.initialProfile,
    );
  }

  bool _validateRequiredDocuments() {
    for (final type in const [
      onboarding_document.DocumentType.license,
      onboarding_document.DocumentType.graduationCertificate,
      onboarding_document.DocumentType.nationalId,
    ]) {
      final selectedFiles = _verificationSectionKey.currentState?.selectedFiles;
      final selectedFile = selectedFiles?[type];
      final existingDocument = _findExistingDocument(type);

      if (selectedFile != null || existingDocument != null) {
        continue;
      }

      showSnackBar(
        context,
        'Please upload ${_requiredDocumentLabel(type)}.',
        Colors.red,
      );
      return false;
    }

    return true;
  }

  profile_document.VerificationDocumentProfileEntity? _findExistingDocument(
    onboarding_document.DocumentType documentType,
  ) {
    final profile = widget.initialProfile;
    if (profile == null) {
      return null;
    }

    for (final document in profile.verificationDocuments) {
      if (_matchesDocumentType(document.documentType, documentType)) {
        return document;
      }
    }

    return null;
  }

  bool _matchesDocumentType(
    profile_document.DocumentType profileType,
    onboarding_document.DocumentType formType,
  ) {
    switch (formType) {
      case onboarding_document.DocumentType.license:
        return profileType == profile_document.DocumentType.license;
      case onboarding_document.DocumentType.graduationCertificate:
        return profileType ==
            profile_document.DocumentType.graduationCertificate;
      case onboarding_document.DocumentType.nationalId:
        return profileType == profile_document.DocumentType.nationalId;
      case onboarding_document.DocumentType.other:
        return profileType == profile_document.DocumentType.other;
    }
  }

  String _requiredDocumentLabel(onboarding_document.DocumentType type) {
    switch (type) {
      case onboarding_document.DocumentType.license:
        return 'your medical license';
      case onboarding_document.DocumentType.graduationCertificate:
        return 'your graduation certificate';
      case onboarding_document.DocumentType.nationalId:
        return 'your national ID';
      case onboarding_document.DocumentType.other:
        return 'the required document';
    }
  }

  String get _resolvedClinicAddress {
    final selectedLocation = _selectedLocation?.trim();
    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      return selectedLocation;
    }

    final addressText = _addressController.text.trim();
    return addressText;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatFee(double fee) {
    if (fee == fee.roundToDouble()) {
      return fee.toStringAsFixed(0);
    }

    return fee.toString();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProfile != null;

    return BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
      listener: (context, state) {
        if (state is ProfileSubmissionFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }

        if (state is ProfileSubmissionSuccess) {
          showSnackBar(
            context,
            isEditing
                ? 'Profile updated successfully.'
                : 'Profile submitted successfully.',
            Colors.green,
          );
          AppRouter.router.go(AppRouter.kDoctorProfileGate);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ProfileSubmissionLoading;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeaderSection(),
              SizedBox(height: 15.h),

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
              ),
              SizedBox(height: 20.h),

              VerificationSection(
                key: _verificationSectionKey,
                existingDocuments:
                    widget.initialProfile?.verificationDocuments ?? const [],
              ),
              SizedBox(height: 20.h),

              BioSection(bioController: _bioController),
              SizedBox(height: 20.h),

              LocationSection(
                clinicNameController: _clinicNameController,
                addressController: _addressController,
                onPickLocation: _showMapPicker,
                selectedLocation: _selectedLocation,
                latitude: _selectedLatitude,
                longitude: _selectedLongitude,
              ),
              SizedBox(height: 20.h),

              OptionalDetailsSection(
                key: _optionalDetailsKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                existingAchievements:
                    widget.initialProfile?.achievements ?? const [],
              ),
              SizedBox(height: 20.h),

              ProfileCompletionButton(
                onPressed: isSubmitting ? null : _validateAndSubmit,
                isLoading: isSubmitting,
                label:
                    isEditing ? 'Update & Resubmit Profile' : 'Submit Profile',
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/get_patient_account_profile_use_case.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/update_patient_onboarding_profile_use_case.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/update_patient_profile_image_use_case.dart';

part 'patient_account_profile_state.dart';

class PatientAccountProfileCubit extends Cubit<PatientAccountProfileState> {
  final GetPatientAccountProfileUseCase getPatientAccountProfileUseCase;
  final UpdatePatientOnboardingProfileUseCase
  updatePatientOnboardingProfileUseCase;
  final UpdatePatientProfileImageUseCase updatePatientProfileImageUseCase;

  PatientAccountProfileEntity? _cachedProfile;

  PatientAccountProfileCubit(
    this.getPatientAccountProfileUseCase,
    this.updatePatientOnboardingProfileUseCase,
    this.updatePatientProfileImageUseCase,
  ) : super(PatientAccountProfileInitial());

  PatientAccountProfileEntity? get cachedProfile => _cachedProfile;

  Future<void> loadProfile() async {
    _emitIfOpen(PatientAccountProfileLoading());

    final result = await getPatientAccountProfileUseCase();
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => _emitIfOpen(PatientAccountProfileFailure(failure.errmessage)),
      (profile) {
        _cachedProfile = profile;
        _emitIfOpen(PatientAccountProfileLoaded(profile));
      },
    );
  }

  Future<void> updateHeaderInfo({
    required String fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    await _updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      successMessage: 'Profile updated successfully',
    );
  }

  Future<void> updateHealthInfo({
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
  }) async {
    await _updateProfile(
      gender: gender,
      bloodType: bloodType,
      height: height,
      weight: weight,
      successMessage: 'Health information updated successfully',
    );
  }

  Future<void> updateProfileImage(File imageFile) async {
    _emitIfOpen(PatientAccountProfileImageUpdateLoading());

    final result = await updatePatientProfileImageUseCase(imageFile);
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        _emitIfOpen(
          PatientAccountProfileImageUpdateFailure(failure.errmessage),
        );
      },
      (profileImage) async {
        if (_cachedProfile != null) {
          _cachedProfile = _cachedProfile!.copyWith(
            profileImageUrl: profileImage.fileUrl,
          );
        }

        _emitIfOpen(
          PatientAccountProfileImageUpdateSuccess(
            'Profile image updated successfully',
          ),
        );

        if (_cachedProfile != null) {
          _emitIfOpen(PatientAccountProfileLoaded(_cachedProfile!));
          return;
        }

        await loadProfile();
      },
    );
  }

  Future<void> _updateProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    required String successMessage,
  }) async {
    _emitIfOpen(PatientAccountProfileUpdateLoading());

    final result = await updatePatientOnboardingProfileUseCase(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodType: bloodType,
      height: height,
      weight: weight,
    );
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        _emitIfOpen(PatientAccountProfileUpdateFailure(failure.errmessage));
      },
      (profile) {
        _cachedProfile = profile;
        _emitIfOpen(PatientAccountProfileUpdateSuccess(successMessage));
        _emitIfOpen(PatientAccountProfileLoaded(profile));
      },
    );
  }

  void _emitIfOpen(PatientAccountProfileState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/slot_config_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/delete_achievement_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_doctor_slot_config_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/replace_verification_document_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_achievement_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_basic_info_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_profile_image_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_real_location_use_case.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../../domain/use_cases/get_doctor_profile_use_case.dart';

class DoctorRealProfileCubit extends Cubit<DoctorRealProfileState> {
  final GetDoctorProfileUseCase getDoctorProfileUseCase;
  final UpdateBasicInfoUseCase updateBasicInfoUseCase;
  final UpdateRealLocationUseCase updateRealLocationUseCase;
  final ReplaceVerificationDocumentUseCase replaceVerificationDocumentUseCase;
  final UpdateAchievementUseCase updateAchievementUseCase;
  final DeleteAchievementUseCase deleteAchievementUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
  final GetDoctorSlotConfigUseCase getDoctorSlotConfigUseCase;

  DoctorRealProfileCubit(
    this.getDoctorProfileUseCase,
    this.updateBasicInfoUseCase,
    this.updateRealLocationUseCase,
    this.replaceVerificationDocumentUseCase,
    this.updateAchievementUseCase,
    this.deleteAchievementUseCase,
    this.updateProfileImageUseCase,
    this.getDoctorSlotConfigUseCase,
  ) : super(DoctorProfileInitial());

  DoctorProfileEntity? _cachedProfile;

  DoctorProfileEntity? get cachedProfile => _cachedProfile;

  List<SlotConfigEntity>? _cachedSlots;
  List<SlotConfigEntity>? get cachedSlots => _cachedSlots;

  Future<void> getDoctorProfile() async {
    emit(DoctorProfileLoading());

    final result = await getDoctorProfileUseCase();

    result.fold((failure) => emit(DoctorProfileFailure(failure.errmessage)), (
      profile,
    ) {
      _cachedProfile = profile;
      emit(DoctorProfileSuccess(profile));
    });
  }

  // ✅ Update Basic Info
  Future<void> updateBasicInfo({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? specialization,
    int? yearsOfExperience,
    double? consultationFee,
    String? description,
    String? nationalId,
  }) async {
    emit(UpdateBasicInfoLoading());
    final result = await updateBasicInfoUseCase(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      consultationFee: consultationFee,
      description: description,
      nationalId: nationalId,
    );
    result.fold((failure) => emit(UpdateBasicInfoFailure(failure.errmessage)), (
      success,
    ) {
      emit(UpdateBasicInfoSuccess());
    });
  }

  // ✅ Update Location
  Future<void> updateLocation({
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
  }) async {
    emit(UpdateRealLocationLoading());
    final result = await updateRealLocationUseCase(
      clinicAddress: clinicAddress,
      latitude: latitude,
      longitude: longitude,
      hospitalName: hospitalName,
    );
    result.fold(
      (failure) => emit(UpdateRealLocationFailure(failure.errmessage)),
      (success) {
        emit(UpdateRealLocationSuccess());
      },
    );
  }

  // ✅ Replace Verification Document
  Future<void> replaceVerificationDocument({
    required int verificationId,
    required File newFile,
  }) async {
    emit(ReplaceVerificationDocumentLoading());
    final result = await replaceVerificationDocumentUseCase(
      verificationId: verificationId,
      newFile: newFile,
    );
    result.fold(
      (failure) => emit(ReplaceVerificationDocumentFailure(failure.errmessage)),
      (success) {
        emit(ReplaceVerificationDocumentSuccess());
      },
    );
  }

  // ✅ Update Achievement
  Future<void> updateAchievement({
    required int achievementId,
    String? title,
    String? description,
    File? image,
  }) async {
    final oldProfile = _cachedProfile;

    // ✅ حدّث الـ cache على طول
    if (_cachedProfile != null) {
      final updatedAchievements =
          _cachedProfile!.achievements.map((a) {
            if (a.achievementId == achievementId) {
              return AchievementProfileEntity(
                achievementId: a.achievementId,
                title: title ?? a.title,
                description: description ?? a.description,
                imageUrl: a.imageUrl, // الصورة هتتحدث بعد الـ refresh
                createdAt: a.createdAt,
              );
            }
            return a;
          }).toList();

      _cachedProfile = DoctorProfileEntity(
        doctorId: _cachedProfile!.doctorId,
        fullName: _cachedProfile!.fullName,
        email: _cachedProfile!.email,
        phoneNumber: _cachedProfile!.phoneNumber,
        dateOfBirth: _cachedProfile!.dateOfBirth,
        nationalId: _cachedProfile!.nationalId,
        specialization: _cachedProfile!.specialization,
        yearsOfExperience: _cachedProfile!.yearsOfExperience,
        consultationFee: _cachedProfile!.consultationFee,
        description: _cachedProfile!.description,
        averageRating: _cachedProfile!.averageRating,
        isActive: _cachedProfile!.isActive,
        isProfileCompleted: _cachedProfile!.isProfileCompleted,
        clinicAddress: _cachedProfile!.clinicAddress,
        clinicLatitude: _cachedProfile!.clinicLatitude,
        clinicLongitude: _cachedProfile!.clinicLongitude,
        hospitalName: _cachedProfile!.hospitalName,
        verificationDocuments: _cachedProfile!.verificationDocuments,
        achievements: updatedAchievements,
      );

      emit(DoctorProfileSuccess(_cachedProfile!));
    }

    final result = await updateAchievementUseCase(
      achievementId: achievementId,
      title: title,
      description: description,
      image: image,
    );

    result.fold(
      (failure) {
        _cachedProfile = oldProfile;
        if (oldProfile != null) emit(DoctorProfileSuccess(oldProfile));
        emit(UpdateAchievementFailure(failure.errmessage));
      },
      (_) {
        emit(UpdateAchievementSuccess());
        getDoctorProfile(); // ✅ refresh في الـ background
      },
    );
  }

  // ✅ Delete Achievement
  Future<void> deleteAchievement({required int achievementId}) async {
    // ✅ احفظ البيانات القديمة عشان ترجعها لو حصل error
    final oldProfile = _cachedProfile;

    // ✅ حدّث الـ cache على طول قبل الـ API
    if (_cachedProfile != null) {
      final updatedAchievements =
          _cachedProfile!.achievements
              .where((a) => a.achievementId != achievementId)
              .toList();

      _cachedProfile = DoctorProfileEntity(
        doctorId: _cachedProfile!.doctorId,
        fullName: _cachedProfile!.fullName,
        email: _cachedProfile!.email,
        phoneNumber: _cachedProfile!.phoneNumber,
        dateOfBirth: _cachedProfile!.dateOfBirth,
        nationalId: _cachedProfile!.nationalId,
        specialization: _cachedProfile!.specialization,
        yearsOfExperience: _cachedProfile!.yearsOfExperience,
        consultationFee: _cachedProfile!.consultationFee,
        description: _cachedProfile!.description,
        averageRating: _cachedProfile!.averageRating,
        isActive: _cachedProfile!.isActive,
        isProfileCompleted: _cachedProfile!.isProfileCompleted,
        clinicAddress: _cachedProfile!.clinicAddress,
        clinicLatitude: _cachedProfile!.clinicLatitude,
        clinicLongitude: _cachedProfile!.clinicLongitude,
        hospitalName: _cachedProfile!.hospitalName,
        verificationDocuments: _cachedProfile!.verificationDocuments,
        achievements: updatedAchievements,
      );

      // ✅ emit على طول بالبيانات الجديدة
      emit(DoctorProfileSuccess(_cachedProfile!));
    }

    // ✅ بعدين عمل الـ API call في الـ background
    final result = await deleteAchievementUseCase(achievementId: achievementId);

    result.fold(
      (failure) {
        // ❌ لو فشل، ارجع للبيانات القديمة
        _cachedProfile = oldProfile;
        if (oldProfile != null) emit(DoctorProfileSuccess(oldProfile));
        emit(DeleteAchievementFailure(failure.errmessage));
      },
      (_) {
        emit(DeleteAchievementSuccess());
        // ✅ refresh في الـ background بدون إنك تستنى نتيجته
        getDoctorProfile();
      },
    );
  }

  // // ✅ Update Achievement
  // Future<void> updateAchievement({
  //   required int achievementId,
  //   String? title,
  //   String? description,
  //   File? image,
  // }) async {
  //   emit(UpdateAchievementLoading());
  //   final result = await updateAchievementUseCase(
  //     achievementId: achievementId,
  //     title: title,
  //     description: description,
  //     image: image,
  //   );
  //   result.fold(
  //     (failure) => emit(UpdateAchievementFailure(failure.errmessage)),
  //     (success) {
  //       emit(UpdateAchievementSuccess());
  //     },
  //   );
  // }

  // // ✅ Delete Achievement
  // Future<void> deleteAchievement({required int achievementId}) async {
  //   emit(DeleteAchievementLoading());
  //   final result = await deleteAchievementUseCase(achievementId: achievementId);
  //   result.fold(
  //     (failure) => emit(DeleteAchievementFailure(failure.errmessage)),
  //     (success) {
  //       emit(DeleteAchievementSuccess());
  //     },
  //   );
  // }

  Future<void> updateProfileImage(File imageFile) async {
    emit(UpdateProfileImageLoading());
    final result = await updateProfileImageUseCase(imageFile);

    result.fold(
      (failure) => emit(UpdateProfileImageFailure(failure.errmessage)),
      (profileImageEntity) {
        if (_cachedProfile != null) {
          // 1. حدث الكاش في صمت
          _cachedProfile = _cachedProfile!.copyWith(
            profileImageUrl: profileImageEntity.fileUrl,
          );
        }

        // 2. ابعت حالة نجاح الصورة فقط (وهي شايلة الـ Entity الجديد)
        // الـ UI كدة كدة بيقرأ من الـ cachedProfile اللي إحنا لسه محدثينه
        emit(UpdateProfileImageSuccess(profileImageEntity));
      },
    );
  }

  Future<void> getDoctorSlotConfig(int doctorId) async {
    emit(GetSlotConfigLoading());
    log('📅 Fetching slot config for doctorId: $doctorId');
    final result = await getDoctorSlotConfigUseCase(doctorId);
    result.fold(
      (failure) {
        log('❌ Failed to fetch slot config: ${failure.errmessage}');
        emit(GetSlotConfigFailure(failure.errmessage));
      },
      (slots) {
        log('✅ Fetched ${slots.length} slot configs');
        for (var slot in slots) {
          log(
            '   🗓️ ${slot.dayName}: ${slot.startTime} - ${slot.endTime} (active: ${slot.isActive})',
          );
        }
        _cachedSlots = slots;
        emit(GetSlotConfigSuccess(slots));
      },
    );
  }
}

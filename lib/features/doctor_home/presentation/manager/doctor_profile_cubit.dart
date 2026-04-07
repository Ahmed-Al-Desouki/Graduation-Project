import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/doctor_home/domain/repositories/doctor_profile_repository.dart';
import '../../domain/entities/complete_profile_request_entity.dart';
import '../../domain/entities/verification_document_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/use_cases/complete_profile_use_case.dart';
import '../../domain/use_cases/upload_verification_document_use_case.dart';
import '../../domain/use_cases/update_location_use_case.dart';
import '../../domain/use_cases/add_achievement_use_case.dart';
import 'doctor_profile_state.dart';

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final CompleteProfileUseCase completeProfileUseCase;
  final UploadVerificationDocumentUseCase uploadDocumentUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final AddAchievementUseCase addAchievementUseCase;
  final DoctorProfileRepository repository;

  DoctorProfileCubit(
    this.completeProfileUseCase,
    this.uploadDocumentUseCase,
    this.updateLocationUseCase,
    this.addAchievementUseCase,
    this.repository,
  ) : super(DoctorProfileInitial());

  // ✅ 1. Complete Profile
  Future<void> completeProfile({
    required String fullName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String specialization,
    required int yearsOfExperience,
    required double consultationFee,
    required String nationalId,
    String? bio,
  }) async {
    emit(CompleteProfileLoading());

    final request = CompleteProfileRequestEntity(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      consultationFee: consultationFee,
      nationalId: nationalId,
      bio: bio,
    );

    final result = await completeProfileUseCase(request);

    result.fold(
      (failure) => emit(CompleteProfileFailure(failure.errmessage)),
      (success) => emit(CompleteProfileSuccess()),
    );
  }

  // ✅ 2. Upload Verification Document
  Future<void> uploadVerificationDocument({
    required DocumentType documentType,
    required File file,
  }) async {
    emit(VerificationDocumentLoading());

    final document = VerificationDocumentEntity(
      documentType: documentType,
      status: VerificationStatus.pending,
      file: file,
    );

    final result = await uploadDocumentUseCase(document);

    result.fold(
      (failure) => emit(VerificationDocumentFailure(failure.errmessage)),
      (success) => emit(VerificationDocumentSuccess()),
    );
  }

  // ✅ 3. Update Location
  Future<void> updateLocation({
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
  }) async {
    emit(UpdateLocationLoading());

    final location = LocationEntity(
      clinicAddress: clinicAddress,
      latitude: latitude,
      longitude: longitude,
      hospitalName: hospitalName,
    );

    final result = await updateLocationUseCase(location);

    result.fold(
      (failure) => emit(UpdateLocationFailure(failure.errmessage)),
      (success) => emit(UpdateLocationSuccess()),
    );
  }

  // ✅ 4. Add Achievement
  Future<void> addAchievement({
    required String title,
    String? description,
    File? image,
  }) async {
    emit(AddAchievementLoading());

    final achievement = AchievementEntity(
      title: title,
      description: description,
      image: image,
    );

    final result = await addAchievementUseCase(achievement);

    result.fold(
      (failure) => emit(AddAchievementFailure(failure.errmessage)),
      (success) => emit(AddAchievementSuccess()),
    );
  }

  // ✅ 5. Check Profile Status (للـ Loading Screen)
  Future<void> checkProfileStatus() async {
    emit(ProfileStatusLoading());

    // TODO: Implement repository method
    final result = await repository.checkProfileStatus();

    result.fold((failure) => emit(ProfileStatusFailure(failure.errmessage)), (
      data,
    ) {
      final isProfileCompleted = data['isProfileCompleted'] as bool;
      final isActive = data['isActive'] as bool;
      emit(
        ProfileStatusSuccess(
          isProfileCompleted: isProfileCompleted,
          isActive: isActive,
        ),
      );
    });
  }

  // ✅ 6. Admin Review Check (Polling every 5 seconds)
  Future<void> startAdminReviewPolling() async {
    emit(AdminReviewLoading());

    // TODO: Implement polling logic
    // Timer.periodic(Duration(seconds: 5), (timer) async {
    //   final result = await checkProfileStatus();
    //   result.fold(
    //     (failure) => emit(AdminReviewRejected(failure.errmessage)),
    //     (data) {
    //       if (data['isActive'] == true) {
    //         timer.cancel();
    //         emit(AdminReviewApproved());
    //       }
    //     },
    //   );
    // });
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';
import 'package:graduation_project/features/doctor_home/domain/repositories/doctor_profile_repository.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/verification_document_profile_entity.dart'
    as profile_document;
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_doctor_profile_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/replace_verification_document_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_basic_info_use_case.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/complete_profile_request_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/verification_document_entity.dart';
import '../../domain/use_cases/add_achievement_use_case.dart';
import '../../domain/use_cases/complete_profile_use_case.dart';
import '../../domain/use_cases/update_location_use_case.dart';
import '../../domain/use_cases/upload_verification_document_use_case.dart';
import 'doctor_profile_state.dart';

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final CompleteProfileUseCase completeProfileUseCase;
  final UploadVerificationDocumentUseCase uploadDocumentUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final AddAchievementUseCase addAchievementUseCase;
  final DoctorProfileRepository repository;
  final GetDoctorProfileUseCase getDoctorProfileUseCase;
  final UpdateBasicInfoUseCase updateBasicInfoUseCase;
  final ReplaceVerificationDocumentUseCase replaceVerificationDocumentUseCase;

  DoctorProfileStatusEntity? _cachedStatus;
  DoctorProfileEntity? _cachedProfile;

  DoctorProfileCubit(
    this.completeProfileUseCase,
    this.uploadDocumentUseCase,
    this.updateLocationUseCase,
    this.addAchievementUseCase,
    this.repository,
    this.getDoctorProfileUseCase,
    this.updateBasicInfoUseCase,
    this.replaceVerificationDocumentUseCase,
  ) : super(DoctorProfileInitial());

  DoctorProfileStatusEntity? get cachedStatus => _cachedStatus;
  DoctorProfileEntity? get cachedProfile => _cachedProfile;

  Future<void> loadDoctorFlow() async {
    emit(DoctorFlowLoading());

    final result = await repository.checkProfileStatus();

    result.fold((failure) => emit(DoctorFlowFailure(failure.errmessage)), (
      status,
    ) {
      _cachedStatus = status;
      emit(DoctorFlowSuccess(status));
    });
  }

  Future<void> loadDoctorProfile() async {
    if (isClosed) return;
    emit(DoctorProfileDataLoading());

    final result = await getDoctorProfileUseCase();

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(DoctorProfileDataFailure(failure.errmessage));
        }
      },
      (profile) {
        _cachedProfile = profile;
        if (!isClosed) {
          emit(DoctorProfileDataSuccess(profile));
        }
      },
    );
  }

  Future<void> submitProfile({
    required String fullName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String specialization,
    required int yearsOfExperience,
    required double consultationFee,
    required String nationalId,
    String? bio,
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
    required Map<DocumentType, File?> verificationFiles,
    List<AchievementEntity> achievements = const [],
    DoctorProfileEntity? existingProfile,
  }) async {
    emit(ProfileSubmissionLoading());

    final profile = existingProfile ?? _cachedProfile;
    Either<Failure, bool> result;

    if (profile != null) {
      result = await updateBasicInfoUseCase(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        specialization: specialization,
        yearsOfExperience: yearsOfExperience,
        consultationFee: consultationFee,
        description: bio,
        nationalId: nationalId,
      );
    } else {
      result = await completeProfileUseCase(
        CompleteProfileRequestEntity(
          fullName: fullName,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          specialization: specialization,
          yearsOfExperience: yearsOfExperience,
          consultationFee: consultationFee,
          nationalId: nationalId,
          bio: bio,
        ),
      );
    }

    if (_handleSubmissionResult(result)) {
      return;
    }

    result = await updateLocationUseCase(
      LocationEntity(
        clinicAddress: clinicAddress,
        latitude: latitude,
        longitude: longitude,
        hospitalName: hospitalName,
      ),
    );

    if (_handleSubmissionResult(result)) {
      return;
    }

    for (final entry in verificationFiles.entries) {
      final file = entry.value;
      if (file == null) {
        continue;
      }

      final existingDocument = _findExistingDocument(profile, entry.key);

      if (existingDocument?.verificationId != null) {
        result = await replaceVerificationDocumentUseCase(
          verificationId: existingDocument!.verificationId,
          newFile: file,
        );
      } else {
        result = await uploadDocumentUseCase(
          VerificationDocumentEntity(
            documentType: entry.key,
            status: VerificationStatus.pending,
            file: file,
          ),
        );
      }

      if (_handleSubmissionResult(result)) {
        return;
      }
    }

    for (final achievement in achievements) {
      result = await addAchievementUseCase(achievement);

      if (_handleSubmissionResult(result)) {
        return;
      }
    }

    final statusResult = await repository.checkProfileStatus();

    statusResult.fold(
      (failure) {
        if (!isClosed) {
          emit(ProfileSubmissionFailure(failure.errmessage));
        }
      },
      (status) {
        _cachedStatus = status;
        if (!isClosed) {
          emit(ProfileSubmissionSuccess(status));
        }
      },
    );
  }

  profile_document.VerificationDocumentProfileEntity? _findExistingDocument(
    DoctorProfileEntity? profile,
    DocumentType documentType,
  ) {
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
    DocumentType formType,
  ) {
    switch (formType) {
      case DocumentType.license:
        return profileType == profile_document.DocumentType.license;
      case DocumentType.graduationCertificate:
        return profileType ==
            profile_document.DocumentType.graduationCertificate;
      case DocumentType.nationalId:
        return profileType == profile_document.DocumentType.nationalId;
      case DocumentType.other:
        return profileType == profile_document.DocumentType.other;
    }
  }

  bool _handleSubmissionResult(Either<Failure, bool> result) {
    var hasFailure = false;

    result.fold((failure) {
      hasFailure = true;
      if (!isClosed) {
        emit(ProfileSubmissionFailure(failure.errmessage));
      }
    }, (_) {});

    return hasFailure;
  }

  Timer? _pollingTimer;

  void startPolling({
    required VoidCallback onApproved,
    required void Function(DoctorProfileStatusEntity) onRejected,
  }) {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final result = await repository.checkProfileStatus();

      result.fold((_) {}, (status) {
        _cachedStatus = status;

        if (status.isApproved || status.isActive) {
          timer.cancel();
          onApproved();
        } else if (status.isRejected) {
          timer.cancel();
          onRejected(status);
        }
      });
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}

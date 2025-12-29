import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/medical_history/data/repository/patient_repo.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:meta/meta.dart';

part 'patient_profile_state.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  final PatientRepository _patientRepository;
  PatientProfileCubit(this._patientRepository) : super(PatientProfileInitial());
  Future<void> getProfile() async {
    emit(PatientProfileLoading());

    final result = await _patientRepository.getPatientProfile();

    result.fold(
      (failure) => emit(PatientProfileFailure(errMessage: failure.errmessage)),
      (profile) => emit(PatientProfileSuccess(profile: profile)),
    );
  }

  Future<void> updateProfileInfo(Map<String, dynamic> updateData) async {
    emit(PatientUpdateLoading());
    final result = await _patientRepository.updateProfile(updateData);

    result.fold(
      (failure) => emit(PatientUpdateFailure(errMessage: failure.errmessage)),
      (profile) {
        emit(PatientUpdateSuccess(message: "Profile updated successfully"));
        emit(PatientProfileSuccess(profile: profile));
      },
    );
  }

  Future<void> uploadMedicalFile({
    required File file,
    required int medicalHistoryId,
    required String category, // "LabTest" or "Radiology"
    required String description,
  }) async {
    emit(PatientUploadLoading());
    final result = await _patientRepository.uploadFile(
      file: file,
      medicalHistoryId: medicalHistoryId,
      category: category,
      description: description,
    );

    result.fold(
      (failure) => emit(PatientUploadFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientUploadSuccess(message: message));
        getProfile();
      },
    );
  }

  Future<void> deleteMedicalFile(int fileId) async {
    final result = await _patientRepository.deleteFile(fileId);

    result.fold(
      (failure) => emit(PatientDeleteFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientDeleteSuccess(message: message));
        getProfile();
      },
    );
  }

  Future<void> addOrUpdateSurgery(SurgeryModel surgery) async {
    emit(PatientOperationLoading());
    final result = await _patientRepository.upsertSurgery(surgery);

    result.fold(
      (failure) =>
          emit(PatientOperationFailure(errMessage: failure.errmessage)),
      (newSurgery) {
        emit(PatientOperationSuccess(message: "Surgery saved successfully"));
        getProfile(); // تحديث الصفحة بالكامل عشان القائمة تتحدث
      },
    );
  }

  // ✅ دالة Upsert Family History
  Future<void> addOrUpdateFamilyHistory(FamilyHistoryModel history) async {
    emit(PatientOperationLoading());
    final result = await _patientRepository.upsertFamilyHistory(history);

    result.fold(
      (failure) =>
          emit(PatientOperationFailure(errMessage: failure.errmessage)),
      (newRecord) {
        emit(PatientOperationSuccess(message: "Family history saved"));
        getProfile();
      },
    );
  }

  // ✅ دالة Upsert Social History
  Future<void> addOrUpdateSocialHistory(SocialHistoryModel history) async {
    emit(PatientOperationLoading());
    final result = await _patientRepository.upsertSocialHistory(history);

    result.fold(
      (failure) =>
          emit(PatientOperationFailure(errMessage: failure.errmessage)),
      (newRecord) {
        emit(PatientOperationSuccess(message: "Social history updated"));
        getProfile();
      },
    );
  }

  // ✅ دالة Upsert Medication
  Future<void> addOrUpdateMedication(MedicationModel medication) async {
    emit(PatientOperationLoading());
    final result = await _patientRepository.upsertMedication(medication);

    result.fold(
      (failure) =>
          emit(PatientOperationFailure(errMessage: failure.errmessage)),
      (newMed) {
        emit(PatientOperationSuccess(message: "Medication saved"));
        getProfile();
      },
    );
  }

  Future<void> deleteSurgery(int surgeryId, int historyId) async {
    final result = await _patientRepository.deleteSurgery(surgeryId, historyId);
    result.fold(
      (failure) => emit(PatientDeleteFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientDeleteSuccess(message: message));
        getProfile(); // تحديث القائمة
      },
    );
  }

  Future<void> deleteFamilyHistory(int familyId, int historyId) async {
    final result = await _patientRepository.deleteFamilyHistory(
      familyId,
      historyId,
    );
    result.fold(
      (failure) => emit(PatientDeleteFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientDeleteSuccess(message: message));
        getProfile();
      },
    );
  }

  Future<void> deleteSocialHistory(int historyId) async {
    final result = await _patientRepository.deleteSocialHistory(historyId);
    result.fold(
      (failure) => emit(PatientDeleteFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientDeleteSuccess(message: message));
        getProfile();
      },
    );
  }

  Future<void> deleteSelfMedication(int selfMedId) async {
    final result = await _patientRepository.deleteSelfMedication(selfMedId);
    result.fold(
      (failure) => emit(PatientDeleteFailure(errMessage: failure.errmessage)),
      (message) {
        emit(PatientDeleteSuccess(message: message));
        getProfile();
      },
    );
  }
}

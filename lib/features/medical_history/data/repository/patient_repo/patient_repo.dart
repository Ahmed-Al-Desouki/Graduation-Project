import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';

abstract class PatientRepository {
  Future<Either<Failure, PatientProfileModel>> getPatientProfile();

  Future<Either<Failure, PatientProfileModel>> updateProfile(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, String>> uploadFile({
    required File file,
    required int medicalHistoryId,
    required String category,
    required String description,
  });

  Future<Either<Failure, String>> deleteFile(int fileId);

  Future<Either<Failure, SurgeryModel>> upsertSurgery(SurgeryModel surgery);
  Future<Either<Failure, FamilyHistoryModel>> upsertFamilyHistory(
    FamilyHistoryModel history,
  );
  Future<Either<Failure, SocialHistoryModel>> upsertSocialHistory(
    SocialHistoryModel history,
  );
  Future<Either<Failure, MedicationModel>> upsertMedication(
    MedicationModel medication,
  );

  Future<Either<Failure, String>> deleteSurgery(int surgeryId, int historyId);
  Future<Either<Failure, String>> deleteFamilyHistory(
    int familyId,
    int historyId,
  );
  Future<Either<Failure, String>> deleteSocialHistory(int historyId);
  Future<Either<Failure, String>> deleteSelfMedication(int selfMedId);
}

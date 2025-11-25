import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';

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
}

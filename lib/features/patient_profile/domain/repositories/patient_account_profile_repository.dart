import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';

abstract class PatientAccountProfileRepository {
  Future<Either<Failure, PatientAccountProfileEntity>> getProfile();

  Future<Either<Failure, PatientAccountProfileEntity>> updateOnboardingProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
  });

  Future<Either<Failure, ProfileImageEntity>> updateProfileImage(File imageFile);
}

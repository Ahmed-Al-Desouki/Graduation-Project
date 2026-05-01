import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/repositories/patient_account_profile_repository.dart';

class UpdatePatientProfileImageUseCase {
  final PatientAccountProfileRepository repository;

  UpdatePatientProfileImageUseCase(this.repository);

  Future<Either<Failure, ProfileImageEntity>> call(File imageFile) async {
    return repository.updateProfileImage(imageFile);
  }
}

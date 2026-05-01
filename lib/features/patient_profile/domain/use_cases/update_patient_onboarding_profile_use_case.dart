import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/repositories/patient_account_profile_repository.dart';

class UpdatePatientOnboardingProfileUseCase {
  final PatientAccountProfileRepository repository;

  UpdatePatientOnboardingProfileUseCase(this.repository);

  Future<Either<Failure, PatientAccountProfileEntity>> call({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
  }) async {
    return repository.updateOnboardingProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodType: bloodType,
      height: height,
      weight: weight,
    );
  }
}

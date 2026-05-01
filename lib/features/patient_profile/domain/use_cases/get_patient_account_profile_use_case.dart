import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/repositories/patient_account_profile_repository.dart';

class GetPatientAccountProfileUseCase {
  final PatientAccountProfileRepository repository;

  GetPatientAccountProfileUseCase(this.repository);

  Future<Either<Failure, PatientAccountProfileEntity>> call() async {
    return repository.getProfile();
  }
}

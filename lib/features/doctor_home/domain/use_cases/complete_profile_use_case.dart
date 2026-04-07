import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/complete_profile_request_entity.dart';
import '../repositories/doctor_profile_repository.dart';

class CompleteProfileUseCase {
  final DoctorProfileRepository repository;

  CompleteProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    CompleteProfileRequestEntity request,
  ) async {
    return await repository.completeProfile(request);
  }
}

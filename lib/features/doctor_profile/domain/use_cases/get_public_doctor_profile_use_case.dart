import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/public_doctor_profile_entity.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class GetPublicDoctorProfileUseCase {
  final DoctorRealProfileRepository repository;

  GetPublicDoctorProfileUseCase(this.repository);

  Future<Either<Failure, PublicDoctorProfileEntity>> call(int doctorId) async {
    return await repository.getPublicDoctorProfile(doctorId);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_profile_entity.dart';
import '../repositories/doctor_real_profile_repository.dart';

class GetDoctorProfileUseCase {
  final DoctorRealProfileRepository repository;

  GetDoctorProfileUseCase(this.repository);

  Future<Either<Failure, DoctorProfileEntity>> call() async {
    return await repository.getDoctorProfile();
  }
}

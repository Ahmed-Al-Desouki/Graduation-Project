import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class UpdateBasicInfoUseCase {
  final DoctorRealProfileRepository repository;

  UpdateBasicInfoUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? specialization,
    int? yearsOfExperience,
    double? consultationFee,
    String? description,
    String? nationalId,
  }) async {
    return await repository.updateBasicInfo(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      consultationFee: consultationFee,
      description: description,
      nationalId: nationalId,
    );
  }
}
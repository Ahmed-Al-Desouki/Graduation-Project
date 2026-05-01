import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class UpdateRealLocationUseCase {
  final DoctorRealProfileRepository repository;

  UpdateRealLocationUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
  }) async {
    return await repository.updateLocation(
      clinicAddress: clinicAddress,
      latitude: latitude,
      longitude: longitude,
      hospitalName: hospitalName,
    );
  }
}

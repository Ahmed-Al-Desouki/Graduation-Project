import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';
import '../repositories/doctor_profile_repository.dart';

class UpdateLocationUseCase {
  final DoctorProfileRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<Either<Failure, bool>> call(LocationEntity location) async {
    return await repository.updateLocation(location);
  }
}

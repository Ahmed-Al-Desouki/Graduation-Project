import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_profile_entity.dart';

abstract class DoctorRealProfileRepository {
  Future<Either<Failure, DoctorProfileEntity>> getDoctorProfile();
}

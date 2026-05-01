import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';

import '../../../../core/errors/failures.dart';
import '../entities/achievement_entity.dart';
import '../entities/complete_profile_request_entity.dart';
import '../entities/location_entity.dart';
import '../entities/verification_document_entity.dart';

abstract class DoctorProfileRepository {
  Future<Either<Failure, bool>> completeProfile(
    CompleteProfileRequestEntity request,
  );

  Future<Either<Failure, bool>> uploadVerificationDocument(
    VerificationDocumentEntity document,
  );

  Future<Either<Failure, bool>> updateLocation(LocationEntity location);

  Future<Either<Failure, bool>> addAchievement(AchievementEntity achievement);

  Future<Either<Failure, DoctorProfileStatusEntity>> checkProfileStatus();
}

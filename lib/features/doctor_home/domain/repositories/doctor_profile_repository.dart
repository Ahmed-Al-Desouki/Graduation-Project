import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/complete_profile_request_entity.dart';
import '../entities/verification_document_entity.dart';
import '../entities/achievement_entity.dart';
import '../entities/location_entity.dart';

abstract class DoctorProfileRepository {
  Future<Either<Failure, bool>> completeProfile(
    CompleteProfileRequestEntity request,
  );

  Future<Either<Failure, bool>> uploadVerificationDocument(
    VerificationDocumentEntity document,
  );

  Future<Either<Failure, bool>> updateLocation(LocationEntity location);

  Future<Either<Failure, bool>> addAchievement(AchievementEntity achievement);

  Future<Either<Failure, Map<String, dynamic>>> checkProfileStatus();
}

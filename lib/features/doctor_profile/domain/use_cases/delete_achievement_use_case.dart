import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class DeleteAchievementUseCase {
  final DoctorRealProfileRepository repository;

  DeleteAchievementUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int achievementId,
  }) async {
    return await repository.deleteAchievement(achievementId: achievementId);
  }
}
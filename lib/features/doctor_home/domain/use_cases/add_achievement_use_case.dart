import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement_entity.dart';
import '../repositories/doctor_profile_repository.dart';

class AddAchievementUseCase {
  final DoctorProfileRepository repository;

  AddAchievementUseCase(this.repository);

  Future<Either<Failure, bool>> call(AchievementEntity achievement) async {
    return await repository.addAchievement(achievement);
  }
}

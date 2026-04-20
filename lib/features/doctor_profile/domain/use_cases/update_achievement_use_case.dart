import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class UpdateAchievementUseCase {
  final DoctorRealProfileRepository repository;

  UpdateAchievementUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int achievementId,
    String? title,
    String? description,
    File? image,
  }) async {
    return await repository.updateAchievement(
      achievementId: achievementId,
      title: title,
      description: description,
      image: image,
    );
  }
}

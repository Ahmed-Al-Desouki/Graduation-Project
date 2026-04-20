import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/doctor_profile/domain/repositories/doctor_real_profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_image_entity.dart';

class UpdateProfileImageUseCase {
  final DoctorRealProfileRepository repository;

  UpdateProfileImageUseCase(this.repository);

  Future<Either<Failure, ProfileImageEntity>> call(File imageFile) async {
    return await repository.updateProfileImage(imageFile);
  }
}

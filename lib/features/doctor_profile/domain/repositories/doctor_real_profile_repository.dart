import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/public_doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/slot_config_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_profile_entity.dart';

abstract class DoctorRealProfileRepository {
  Future<Either<Failure, DoctorProfileEntity>> getDoctorProfile();

  Future<Either<Failure, bool>> updateBasicInfo({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? specialization,
    int? yearsOfExperience,
    double? consultationFee,
    String? bio,
    String? nationalId,
  });

  Future<Either<Failure, bool>> updateLocation({
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
  });

  Future<Either<Failure, bool>> replaceVerificationDocument({
    required int verificationId,
    required File newFile,
  });

  Future<Either<Failure, bool>> updateAchievement({
    required int achievementId,
    String? title,
    String? description,
    File? image,
  });

  Future<Either<Failure, bool>> deleteAchievement({required int achievementId});

  Future<Either<Failure, ProfileImageEntity>> updateProfileImage(
    File imageFile,
  );

  Future<Either<Failure, List<SlotConfigEntity>>> getDoctorSlotConfig(
    int doctorId,
  );

  Future<Either<Failure, PublicDoctorProfileEntity>> getPublicDoctorProfile(
    int doctorId,
  );
}

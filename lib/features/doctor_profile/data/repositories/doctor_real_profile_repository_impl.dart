import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/slot_config_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/repositories/doctor_real_profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../data_sources/doctor_profile_remote_data_source.dart';

class DoctorRealProfileRepositoryImpl implements DoctorRealProfileRepository {
  final DoctorProfileRemoteDataSource remoteDataSource;

  DoctorRealProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DoctorProfileEntity>> getDoctorProfile() async {
    try {
      final result = await remoteDataSource.getDoctorProfile();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBasicInfo({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? specialization,
    int? yearsOfExperience,
    double? consultationFee,
    String? description,
    String? nationalId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) {
        body['dateOfBirth'] = dateOfBirth.toUtc().toIso8601String();
      }
      if (specialization != null) body['specialization'] = specialization;
      if (yearsOfExperience != null) {
        body['yearsOfExperience'] = yearsOfExperience;
      }
      if (consultationFee != null) body['consultationFee'] = consultationFee;
      if (description != null) body['description'] = description;
      if (nationalId != null) body['nationalId'] = nationalId;

      if (body.isEmpty) return Right(true); // No changes to update

      final result = await remoteDataSource.updateBasicInfo(body);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLocation({
    String? clinicAddress,
    double? latitude,
    double? longitude,
    String? hospitalName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (clinicAddress != null) body['clinicAddress'] = clinicAddress;
      if (latitude != null) body['clinicLatitude'] = latitude;
      if (longitude != null) body['clinicLongitude'] = longitude;
      if (hospitalName != null) body['hospitalName'] = hospitalName;

      if (body.isEmpty) return Right(true);

      final result = await remoteDataSource.updateLocation(body);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> replaceVerificationDocument({
    required int verificationId,
    required File newFile,
  }) async {
    try {
      final result = await remoteDataSource.replaceVerificationDocument(
        verificationId: verificationId,
        newFile: newFile,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAchievement({
    required int achievementId,
    String? title,
    String? description,
    File? image,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;

      final result = await remoteDataSource.updateAchievement(
        achievementId: achievementId,
        body: body,
        image: image,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAchievement({
    required int achievementId,
  }) async {
    try {
      final result = await remoteDataSource.deleteAchievement(achievementId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileImageEntity>> updateProfileImage(
    File imageFile,
  ) async {
    try {
      final result = await remoteDataSource.updateProfileImage(imageFile);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SlotConfigEntity>>> getDoctorSlotConfig(
    int doctorId,
  ) async {
    try {
      final result = await remoteDataSource.getDoctorSlotConfig(doctorId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

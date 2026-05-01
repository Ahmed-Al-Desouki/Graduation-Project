import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/patient_profile/data/data_sources/patient_account_profile_remote_data_source.dart';
import 'package:graduation_project/features/patient_profile/data/models/patient_account_profile_model.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/domain/repositories/patient_account_profile_repository.dart';

class PatientAccountProfileRepositoryImpl
    implements PatientAccountProfileRepository {
  final PatientAccountProfileRemoteDataSource remoteDataSource;

  PatientAccountProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PatientAccountProfileEntity>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      final data =
          (response['success'] == true && response['data'] != null)
              ? response['data'] as Map<String, dynamic>
              : response;

      return Right(PatientAccountProfileModel.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientAccountProfileEntity>> updateOnboardingProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (fullName != null) {
        body['fullName'] = fullName;
      }
      if (phoneNumber != null) {
        body['phoneNumber'] = phoneNumber;
      }
      if (dateOfBirth != null) {
        body['dateOfBirth'] = dateOfBirth.toUtc().toIso8601String();
      }
      if (gender != null) {
        body['gender'] = gender;
      }
      if (bloodType != null) {
        body['bloodType'] = bloodType;
      }
      if (height != null) {
        body['height'] = height % 1 == 0 ? height.toInt() : height;
      }
      if (weight != null) {
        body['weight'] = weight % 1 == 0 ? weight.toInt() : weight;
      }

      if (body.isNotEmpty) {
        await remoteDataSource.updateOnboardingProfile(body);
      }

      final refreshedProfile = await getProfile();
      return refreshedProfile;
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
      final response = await remoteDataSource.updateProfileImage(imageFile);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

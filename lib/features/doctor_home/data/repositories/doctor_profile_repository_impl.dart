import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/features/doctor_home/data/models/location_model.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/location_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/complete_profile_request_entity.dart';
import '../../domain/entities/verification_document_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../data_sources/doctor_profile_remote_data_source.dart';
import '../models/complete_profile_request_model.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  final DoctorProfileRemoteDataSource remoteDataSource;

  DoctorProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> completeProfile(
    CompleteProfileRequestEntity request,
  ) async {
    try {
      final model = CompleteProfileRequestModel(
        fullName: request.fullName,
        phoneNumber: request.phoneNumber,
        dateOfBirth: request.dateOfBirth,
        specialization: request.specialization,
        yearsOfExperience: request.yearsOfExperience,
        consultationFee: request.consultationFee,
        nationalId: request.nationalId,
        bio: request.bio,
      );

      final result = await remoteDataSource.completeProfile(model);
      return Right(result);
    } on DioException catch (e) {
      // ✅ استخدم الـ method الجديد
      return Left(
        ServerFailure.fromPlainStringResponse(
          e.response?.statusCode,
          e.response?.data,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> uploadVerificationDocument(
    VerificationDocumentEntity document,
  ) async {
    try {
      if (document.file == null) {
        return Left(ServerFailure('No file selected'));
      }

      final result = await remoteDataSource.uploadVerificationDocument(
        documentType: document.documentType.value,
        file: document.file!,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLocation(LocationEntity location) async {
    try {
      final model = LocationModel(
        clinicAddress: location.clinicAddress,
        latitude: location.latitude,
        longitude: location.longitude,
        hospitalName: location.hospitalName,
      );

      final result = await remoteDataSource.updateLocation(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addAchievement(
    AchievementEntity achievement,
  ) async {
    try {
      final result = await remoteDataSource.addAchievement(
        title: achievement.title,
        description: achievement.description,
        image: achievement.image,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkProfileStatus() async {
    try {
      final result = await remoteDataSource.checkProfileStatus();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/medical_history/data/repository/patient_repo.dart';
import 'package:graduation_project/features/medical_history/data/service/patient_web_service.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientWebServices _patientWebServices;

  PatientRepositoryImpl(this._patientWebServices);

  @override
  Future<Either<Failure, PatientProfileModel>> getPatientProfile() async {
    try {
      final response = await _patientWebServices.getPatientProfile();
      print("🔍 Raw Profile Data: ${response['data']}");
      if (response['success'] == true && response['data'] != null) {
        return Right(PatientProfileModel.fromJson(response['data']));
      }
      return Left(
        ServerFailure(response['message'] ?? 'Failed to load profile'),
      );
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _patientWebServices.updatePatientProfile(data);
      if (response['success'] == true && response['data'] != null) {
        return Right(PatientProfileModel.fromJson(response['data']));
      }
      return Left(ServerFailure(response['message'] ?? 'Update failed'));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required int medicalHistoryId,
    required String category,
    required String description,
  }) async {
    try {
      final response = await _patientWebServices.uploadFile(
        file: file,
        medicalHistoryId: medicalHistoryId,
        category: category,
        description: description,
      );
      // الـ Response فيه message و file object، احنا يهمنا الـ success message حالياً
      // ممكن ترجع File Model لو حابب، بس الـ String كفاية عشان نعيد تحميل البروفايل
      return Right(response['message'] ?? 'Uploaded successfully');
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteFile(int fileId) async {
    try {
      final response = await _patientWebServices.deleteFile(fileId);
      return Right(response['message'] ?? 'Deleted successfully');
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }
}

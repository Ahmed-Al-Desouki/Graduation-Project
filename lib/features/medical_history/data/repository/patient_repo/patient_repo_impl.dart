import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/medical_history/data/repository/patient_repo/patient_repo.dart';
import 'package:graduation_project/features/medical_history/data/service/patient_web_service.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientWebServices _patientWebServices;

  PatientRepositoryImpl(this._patientWebServices);

  // @override
  // Future<Either<Failure, PatientProfileModel>> getPatientProfile() async {
  //   try {
  //     final response = await _patientWebServices.getPatientProfile();
  //     print("🔍 Raw Profile Data: ${response['data']}");
  //     if (response['success'] == true && response['data'] != null) {
  //       return Right(PatientProfileModel.fromJson(response['data']));
  //     }
  //     return Left(
  //       ServerFailure(response['message'] ?? 'Failed to load profile'),
  //     );
  //   } catch (e) {
  //     if (e is DioException) return Left(ServerFailure.fromDioException(e));
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }
  @override
  Future<Either<Failure, PatientProfileModel>> getPatientProfile() async {
    try {
      // 1. هات الرد
      final response = await _patientWebServices.getPatientProfile();

      // 2. اطبع الرد عشان نتأكد
      print("🔍 API Response: $response");

      // 3. تأكد من الهيكلة (ممكن الباك إيند شال كلمة success ورجع الداتا علطول)
      // السيناريو أ: الرد فيه { success: true, data: { ... } }
      if (response['success'] == true && response['data'] != null) {
        return Right(PatientProfileModel.fromJson(response['data']));
      }
      // السيناريو ب: الرد هو الداتا علطول { patientID: 4, ... }
      else if (response['patientID'] != null) {
        return Right(PatientProfileModel.fromJson(response));
      }

      return Left(
        ServerFailure(response['message'] ?? 'Failed to load profile'),
      );
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  // @override
  // Future<Either<Failure, PatientProfileModel>> updateProfile(
  //   Map<String, dynamic> data,
  // ) async {
  //   try {
  //     final response = await _patientWebServices.updatePatientProfile(data);
  //     if (response['success'] == true && response['data'] != null) {
  //       return Right(PatientProfileModel.fromJson(response['data']));
  //     }
  //     return Left(ServerFailure(response['message'] ?? 'Update failed'));
  //   } catch (e) {
  //     if (e is DioException) return Left(ServerFailure.fromDioException(e));
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, PatientProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _patientWebServices.updatePatientProfile(data);

      // طباعة للدييباج عشان نتأكد
      print("🔍 Update Response: $response");

      // 1. الحالة الأولى: الرد مغلف بـ success و data
      if (response['success'] == true && response['data'] != null) {
        return Right(PatientProfileModel.fromJson(response['data']));
      }
      // 2. الحالة الثانية (الحالية): الرد هو الداتا مباشرة
      // بنتأكد بوجود حقل مميز زي patientID
      else if (response['patientID'] != null) {
        return Right(PatientProfileModel.fromJson(response));
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

  @override
  Future<Either<Failure, SurgeryModel>> upsertSurgery(
    SurgeryModel surgery,
  ) async {
    try {
      final response = await _patientWebServices.upsertSurgery(
        surgery.toJson(),
      );
      // نتأكد هل الداتا راجعة مباشرة ولا جوه 'data'
      final data = response['data'] ?? response;
      return Right(SurgeryModel.fromJson(data));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ تنفيذ Upsert Family History
  @override
  Future<Either<Failure, FamilyHistoryModel>> upsertFamilyHistory(
    FamilyHistoryModel history,
  ) async {
    try {
      final response = await _patientWebServices.upsertFamilyHistory(
        history.toJson(),
      );
      final data = response['data'] ?? response;
      return Right(FamilyHistoryModel.fromJson(data));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ تنفيذ Upsert Social History
  @override
  Future<Either<Failure, SocialHistoryModel>> upsertSocialHistory(
    SocialHistoryModel history,
  ) async {
    try {
      final response = await _patientWebServices.upsertSocialHistory(
        history.toJson(),
      );
      final data = response['data'] ?? response;
      return Right(SocialHistoryModel.fromJson(data));
    } on DioException catch (e) {
      // هذه الأسطر ستخبرك بالضبط ما هو الحقل المرفوض ولماذا
      print("❌ Server Validation Error: ${e.response?.data}");
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ تنفيذ Upsert Medication
  @override
  Future<Either<Failure, MedicationModel>> upsertMedication(
    MedicationModel medication,
  ) async {
    try {
      final response = await _patientWebServices.upsertSelfMedication(
        medication.toJson(),
      );
      final data = response['data'] ?? response;
      print(data);
      return Right(MedicationModel.fromJson(data));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteSurgery(
    int surgeryId,
    int historyId,
  ) async {
    try {
      await _patientWebServices.deleteSurgery(surgeryId, historyId);
      return const Right("Surgery deleted successfully");
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteFamilyHistory(
    int familyId,
    int historyId,
  ) async {
    try {
      await _patientWebServices.deleteFamilyHistory(familyId, historyId);
      return const Right("Record deleted successfully");
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteSocialHistory(int historyId) async {
    try {
      await _patientWebServices.deleteSocialHistory(historyId);
      return const Right("Social history deleted");
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteSelfMedication(int selfMedId) async {
    try {
      await _patientWebServices.deleteSelfMedication(selfMedId);
      return const Right("Medication deleted");
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioException(e));
      return Left(ServerFailure(e.toString()));
    }
  }
}

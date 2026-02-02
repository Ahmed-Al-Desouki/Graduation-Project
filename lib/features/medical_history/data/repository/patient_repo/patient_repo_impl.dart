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

  Future<Either<Failure, T>> _taskWrapper<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientProfileModel>> getPatientProfile() async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.getPatientProfile();
      final data =
          (response['success'] == true && response['data'] != null)
              ? response['data']
              : response;

      if (data['patientID'] != null) {
        return PatientProfileModel.fromJson(data);
      }
      throw Exception(response['message'] ?? 'Failed to load profile');
    });
  }

  @override
  Future<Either<Failure, PatientProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.updatePatientProfile(data);
      final responseData =
          (response['success'] == true && response['data'] != null)
              ? response['data']
              : response;

      if (responseData['patientID'] != null) {
        return PatientProfileModel.fromJson(responseData);
      }
      throw Exception(response['message'] ?? 'Update failed');
    });
  }

  @override
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required int medicalHistoryId,
    required String category,
    required String description,
  }) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.uploadFile(
        file: file,
        medicalHistoryId: medicalHistoryId,
        category: category,
        description: description,
      );
      // return response['message'] ?? 'Uploaded successfully';
      if (response['success'] == true) {
        return response['message'] ?? 'Uploaded successfully';
      } else {
        throw Exception(response['message'] ?? 'Failed to upload');
      }
    });
  }

  @override
  Future<Either<Failure, String>> deleteFile(int fileId) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.deleteFile(fileId);
      return response['message'] ?? 'Deleted successfully';
    });
  }

  @override
  Future<Either<Failure, SurgeryModel>> upsertSurgery(
    SurgeryModel surgery,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.upsertSurgery(
        surgery.toJson(),
      );
      final data = response['data'] ?? response;
      return SurgeryModel.fromJson(data);
    });
  }

  @override
  Future<Either<Failure, FamilyHistoryModel>> upsertFamilyHistory(
    FamilyHistoryModel history,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.upsertFamilyHistory(
        history.toJson(),
      );
      final data = response['data'] ?? response;
      return FamilyHistoryModel.fromJson(data);
    });
  }

  @override
  Future<Either<Failure, SocialHistoryModel>> upsertSocialHistory(
    SocialHistoryModel history,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.upsertSocialHistory(
        history.toJson(),
      );
      final data = response['data'] ?? response;
      return SocialHistoryModel.fromJson(data);
    });
  }

  @override
  Future<Either<Failure, MedicationModel>> upsertMedication(
    MedicationModel medication,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.upsertSelfMedication(
        medication.toJson(),
      );
      final data = response['data'] ?? response;
      return MedicationModel.fromJson(data);
    });
  }

  @override
  Future<Either<Failure, String>> deleteSurgery(
    int surgeryId,
    int historyId,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.deleteSurgery(
        surgeryId,
        historyId,
      );
      if (response == null || response is String || response.isEmpty) {
        return "Record deleted successfully";
      }
      return response['message'] ?? "Surgery deleted successfully";
    });
  }

  @override
  Future<Either<Failure, String>> deleteFamilyHistory(
    int familyId,
    int historyId,
  ) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.deleteFamilyHistory(
        familyId,
        historyId,
      );

      if (response == null || response is String || response.isEmpty) {
        return "Record deleted successfully";
      }
      return response['message'] ?? "Record deleted successfully";
    });
  }

  @override
  Future<Either<Failure, String>> deleteSocialHistory(int historyId) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.deleteSocialHistory(historyId);
      if (response == null || response is String || response.isEmpty) {
        return "Record deleted successfully";
      }
      return response['message'] ?? "Social history deleted";
    });
  }

  @override
  Future<Either<Failure, String>> deleteSelfMedication(int selfMedId) async {
    return _taskWrapper(() async {
      final response = await _patientWebServices.deleteSelfMedication(
        selfMedId,
      );
      if (response == null || response is String || response.isEmpty) {
        return "Record deleted successfully";
      }
      return response['message'] ?? "Medication deleted";
    });
  }
}

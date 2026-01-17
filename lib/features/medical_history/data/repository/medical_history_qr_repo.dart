import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/medical_history/data/service/medical_history_qr_service.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';

class MedicalHistoryQrRepository {
  final MedicalHistoryQrService _qrService;

  MedicalHistoryQrRepository(this._qrService);

  Future<Either<Failure, Map<String, String>>> generateQrCode({
    required int patientId,
    required int medicalHistoryId,
  }) async {
    try {
      final response = await _qrService.generateQrCode(
        patientId: patientId,
        medicalHistoryId: medicalHistoryId,
      );

      final token = response['token'];
      final qrCodeBase64 = response['qrCodeBase64'];
      return Right({'token': token!, 'qrCodeBase64': qrCodeBase64!});
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PatientProfileModel>> getSharedHistory(
    String token,
  ) async {
    try {
      final response = await _qrService.getSharedHistory(token);

      if (response['success'] == true && response['profile'] != null) {
        final model = PatientProfileModel.fromJson(response['profile']);
        return Right(model);
      } else {
        return Left(ServerFailure("Failed to load profile data"));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'dart:developer';

import 'package:graduation_project/core/utils/helper/api.dart';

class MedicalHistoryQrService {
  final ApiService _apiService;

  MedicalHistoryQrService(this._apiService);

  Future<Map<String, String>> generateQrCode({
    required int patientId,
    required int medicalHistoryId,
  }) async {
    final response = await _apiService.post("share/generate", {
      "PatientId": patientId,
      "MedicalHistoryId": medicalHistoryId,
    });

    if (response != null &&
        response['shareToken'] != null &&
        response['message'] != null) {
      final token = response['shareToken'];
      final qrCodeBase64 = response['message'];
      return {'token': token, 'qrCodeBase64': qrCodeBase64};
    } else {
      throw Exception("Invalid response: QR Code not found");
    }
  }

  Future<Map<String, dynamic>> getSharedHistory(String token) async {
    final response = await _apiService.get(
      "share/medical-profile",
      queryParameters: {'token': token},
    );
    log(" Raw Data from Server: $response");
    return response;
  }
}

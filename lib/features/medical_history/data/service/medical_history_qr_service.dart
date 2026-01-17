import 'package:graduation_project/core/utils/helper/api.dart';

class MedicalHistoryQrService {
  final ApiService _apiService;

  MedicalHistoryQrService(this._apiService);

  Future<Map<String, String>> generateQrCode({
    required int patientId,
    required int medicalHistoryId,
  }) async {
    final response = await _apiService.post(
      "ShareMediHistoryQrCode/generate-qr",
      {"PatientId": patientId, "MedicalHistoryId": medicalHistoryId},
    );

    if (response != null &&
        response['qrCodeBase64'] != null &&
        response['token'] != null) {
      final token = response['token'];
      final qrCodeBase64 = response['qrCodeBase64'];
      return {'token': token, 'qrCodeBase64': qrCodeBase64};
    } else {
      throw Exception("Invalid response: QR Code not found");
    }
  }

  Future<Map<String, dynamic>> getSharedHistory(String token) async {
    final response = await _apiService.get(
      "ShareMediHistoryQrCode/share-medical-history",
      queryParameters: {'token': token},
    );
    print(" Raw Data from Server: $response");
    return response;
  }
}

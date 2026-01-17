import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'dart:io';

class PatientWebServices {
  final ApiService _apiService;

  PatientWebServices(this._apiService);

  Future<Map<String, dynamic>> getPatientProfile() async {
    return await _apiService.get('PatientMedicalProfile/profile');
  }

  Future<Map<String, dynamic>> updatePatientProfile(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.put('PatientMedicalProfile/profile', body);
  }

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required int medicalHistoryId,
    required String category,
    required String description,
  }) async {
    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'MedicalHistoryId': medicalHistoryId,
      'Category': category,
      'Description': description,
    });

    return await _apiService.post('patient/files/upload', formData);
  }

  Future<Map<String, dynamic>> deleteFile(int fileId) async {
    return await _apiService.delete('patient/files/delete/$fileId');
  }

  Future<Map<String, dynamic>> upsertSurgery(Map<String, dynamic> body) async {
    return await _apiService.post('PatientMedicalProfile/surgery', body);
  }

  Future<Map<String, dynamic>> upsertFamilyHistory(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post('PatientMedicalProfile/family-history', body);
  }

  Future<Map<String, dynamic>> upsertSocialHistory(
    Map<String, dynamic> body,
  ) async {
    print("📤 Sending Social History Data: ${jsonEncode(body)}");
    return await _apiService.post('PatientMedicalProfile/social-history', body);
  }

  Future<Map<String, dynamic>> upsertMedication(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post(
      'PatientMedicalProfile/self-medications',
      body,
    );
  }

  Future<Map<String, dynamic>> upsertSelfMedication(
    Map<String, dynamic> body,
  ) async {
    print("📡 Sending Medication Data: $body");
    return await _apiService.post(
      'PatientMedicalProfile/self-medications',
      body,
    );
  }

  Future<dynamic> deleteSurgery(int surgeryId, int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/surgery/$surgeryId/history/$historyId',
    );
  }

  Future<dynamic> deleteFamilyHistory(int familyId, int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/family-history/$familyId/history/$historyId',
    );
  }

  Future<dynamic> deleteSocialHistory(int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/social-history/history/$historyId',
    );
  }

  Future<dynamic> deleteSelfMedication(int selfMedId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/self-medications/$selfMedId',
    );
  }

  Future<String> generateMedicalHistoryQr({
    required String patientId,
    required int medicalHistoryId,
  }) async {
    final response = await _apiService.post(
      "/api/ShareMediHistoryQrCode/generate-qr",
      {"PatientId": int.parse(patientId), "MedicalHistoryId": medicalHistoryId},
    );

    if (response['qrCodeBase64'] != null) {
      return response['qrCodeBase64'];
    } else {
      throw Exception("Failed to generate QR Code");
    }
  }
}

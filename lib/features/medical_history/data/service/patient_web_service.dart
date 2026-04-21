import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'dart:io';

class PatientWebServices {
  final ApiService _apiService;

  PatientWebServices(this._apiService);

  Future<Map<String, dynamic>> getPatientProfile() async {
    return await _apiService.get('medical-profile');
  }

  Future<Map<String, dynamic>> updatePatientProfile(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.put('medical-profile', body);
  }

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required int medicalHistoryId,
    required String category,
    required String description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last.replaceAll(RegExp(r'[^\w\.]'), '_'),
      ),
      'medicalHistoryId': medicalHistoryId,
      'category': category.replaceAll(' ', ''),
      'description': description,
    });

    return await _apiService.post('patient/files/upload', formData);
  }

  Future<Map<String, dynamic>> deleteFile(int fileId) async {
    return await _apiService.delete('patient/files/delete/$fileId');
  }

  Future<Map<String, dynamic>> upsertSurgery(Map<String, dynamic> body) async {
    return await _apiService.post('medical-history/surgery', body);
  }

  Future<Map<String, dynamic>> upsertFamilyHistory(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post('medical-history/family-history', body);
  }

  Future<Map<String, dynamic>> upsertSocialHistory(
    Map<String, dynamic> body,
  ) async {
    log("📤 Sending Social History Data: ${jsonEncode(body)}");
    return await _apiService.post('medical-history/social-history', body);
  }

  Future<Map<String, dynamic>> upsertMedication(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post('medical-history/self-medication', body);
  }

  Future<Map<String, dynamic>> upsertSelfMedication(
    Map<String, dynamic> body,
  ) async {
    log("📡 Sending Medication Data: $body");
    return await _apiService.post('medical-history/self-medication', body);
  }

  Future<dynamic> deleteSurgery(int surgeryId, int historyId) async {
    return await _apiService.delete(
      'medical-history/surgery/$surgeryId/history/$historyId',
    );
  }

  Future<dynamic> deleteFamilyHistory(int familyId, int historyId) async {
    return await _apiService.delete(
      'medical-history/family-history/$familyId/history/$historyId',
    );
  }

  Future<dynamic> deleteSocialHistory(int historyId) async {
    return await _apiService.delete(
      'medical-history/social-history/history/$historyId',
    );
  }

  Future<dynamic> deleteSelfMedication(int selfMedId) async {
    return await _apiService.delete(
      'medical-history/self-medication/$selfMedId',
    );
  }

  Future<String> generateMedicalHistoryQr({
    required String patientId,
    required int medicalHistoryId,
  }) async {
    final response = await _apiService.post("/api/share/generate", {
      "PatientId": int.parse(patientId),
      "MedicalHistoryId": medicalHistoryId,
    });

    if (response['qrCodeBase64'] != null) {
      return response['qrCodeBase64'];
    } else {
      throw Exception("Failed to generate QR Code");
    }
  }
}

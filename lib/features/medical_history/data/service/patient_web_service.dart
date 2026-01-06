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
    required String category, // "LabTest", "Radiology", "Other"
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
    // الـ Endpoint مش مذكورة بالظبط في الدوكيمنتشن كـ URL، بس غالباً هتكون كدة بناءً على النمط
    // لو الباك إيند مبعتلكش الـ URL، استخدم ده وجرب أو اسأله
    // Update: بناءً على اسم السيرفيس، ممكن تكون PatientMedicalProfile/surgery/upsert
    // أنا هستخدم المسار المنطقي، وعدله لو الباك إيند عنده مسار مختلف
    return await _apiService.post('PatientMedicalProfile/surgery', body);
  }

  // 2. Upsert Family History
  Future<Map<String, dynamic>> upsertFamilyHistory(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post('PatientMedicalProfile/family-history', body);
  }

  // 3. Upsert Social History
  Future<Map<String, dynamic>> upsertSocialHistory(
    Map<String, dynamic> body,
  ) async {
    print("📤 Sending Social History Data: ${jsonEncode(body)}");
    return await _apiService.post('PatientMedicalProfile/social-history', body);
  }

  // 4. Upsert Medication
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
    return await _apiService.post(
      'PatientMedicalProfile/self-medications',
      body,
    );
  }

  // ✅ 1. Delete Surgery
  // الرابط الجديد: PatientMedicalProfile/surgery/{surgeryId}/history/{historyId}
  Future<dynamic> deleteSurgery(int surgeryId, int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/surgery/$surgeryId/history/$historyId',
    );
  }

  // ✅ 2. Delete Family History
  // غالباً هيكون نفس النمط: PatientMedicalProfile/family-history/{id}/history/{historyId}
  Future<dynamic> deleteFamilyHistory(int familyId, int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/family-history/$familyId/history/$historyId',
    );
  }

  // ✅ 3. Delete Social History
  // في التوثيق القديم كان MedicalHistories، بس غالباً اتغير لـ PatientMedicalProfile
  // جرب: PatientMedicalProfile/social-history/history/{historyId}
  Future<dynamic> deleteSocialHistory(int historyId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/social-history/history/$historyId',
    );
  }

  // ✅ 4. Delete Self Medication
  // ده بيحتاج ID الدواء بس، بس تأكد من المسار
  // غالباً: PatientMedicalProfile/self-medication/{id}
  Future<dynamic> deleteSelfMedication(int selfMedId) async {
    return await _apiService.delete(
      'PatientMedicalProfile/self-medications/$selfMedId',
    );
  }

  // ضيف دي في MedicalHistoryWebService
  Future<String> generateMedicalHistoryQr({
    required String patientId,
    required int medicalHistoryId,
  }) async {
    // الـ API حسب التوثيق اللي بعته
    final response = await _apiService.post(
      "/api/ShareMediHistoryQrCode/generate-qr",
      {
        "PatientId": int.parse(
          patientId,
        ), // تأكد لو الباك بيقبلها int ولا String
        "MedicalHistoryId": medicalHistoryId,
      },
    );

    // الـ Response بيرجع json فيه token و qrCodeBase64
    if (response['qrCodeBase64'] != null) {
      return response['qrCodeBase64'];
    } else {
      throw Exception("Failed to generate QR Code");
    }
  }
}

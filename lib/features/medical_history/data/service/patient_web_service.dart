import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'dart:io';

class PatientWebServices {
  final ApiService _apiService;

  PatientWebServices(this._apiService);

  Future<Map<String, dynamic>> getPatientProfile() async {
    return await _apiService.get('patient/profile');
  }

  Future<Map<String, dynamic>> updatePatientProfile(
    Map<String, dynamic> body,
  ) async {
    return await _apiService.put('patient/profile', body);
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
}

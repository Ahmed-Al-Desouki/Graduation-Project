import 'dart:io';

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/doctor_home/data/data_sources/doctor_profile_remote_data_source.dart';
import 'package:graduation_project/features/doctor_home/data/models/complete_profile_request_model.dart';
import 'package:graduation_project/features/doctor_home/data/models/location_model.dart';

class DoctorProfileRemoteDataSourceImpl
    implements DoctorProfileRemoteDataSource {
  final ApiService _apiService;

  DoctorProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<bool> completeProfile(CompleteProfileRequestModel request) async {
    final response = await _apiService.post(
      'doctor/profile/complete',
      request.toJson(),
    );
    return response != null;
  }

  @override
  Future<bool> uploadVerificationDocument({
    required int documentType,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'documentType': documentType,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await _apiService.postMultipart(
      'doctor/profile/verification-documents',
      formData,
    );
    return response != null;
  }

  @override
  Future<bool> updateLocation(LocationModel location) async {
    final response = await _apiService.patch(
      'doctor/profile/location',
      body: location.toJson(),
    );
    return response != null;
  }

  @override
  Future<bool> addAchievement({
    required String title,
    String? description,
    File? image,
  }) async {
    final Map<String, dynamic> fields = {'title': title};

    if (description != null) {
      fields['description'] = description;
    }

    if (image != null) {
      fields['image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(fields);

    final response = await _apiService.postMultipart(
      'doctor/profile/achievements',
      formData,
    );
    return response != null;
  }

  @override
  Future<Map<String, dynamic>> checkProfileStatus() async {
    final response = await _apiService.get('doctor/profile');
    return response as Map<String, dynamic>;
  }
}

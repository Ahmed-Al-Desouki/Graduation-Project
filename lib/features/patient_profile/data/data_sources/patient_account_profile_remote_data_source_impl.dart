import 'dart:io';

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/doctor_profile/data/models/profile_image_model.dart';
import 'package:graduation_project/features/patient_profile/data/data_sources/patient_account_profile_remote_data_source.dart';

class PatientAccountProfileRemoteDataSourceImpl
    implements PatientAccountProfileRemoteDataSource {
  final ApiService apiService;

  PatientAccountProfileRemoteDataSourceImpl(this.apiService);

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await apiService.get('patient/profile');
    return response as Map<String, dynamic>;
  }

  @override
  Future<dynamic> updateOnboardingProfile(Map<String, dynamic> body) async {
    return apiService.patch('patient/profile/onboarding', body: body);
  }

  @override
  Future<ProfileImageModel> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await apiService.putMultipart(
      'profile-image/update',
      formData,
    );

    return ProfileImageModel.fromJson(response as Map<String, dynamic>);
  }
}

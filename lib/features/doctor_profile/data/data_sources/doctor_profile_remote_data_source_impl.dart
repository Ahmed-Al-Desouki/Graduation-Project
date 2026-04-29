import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/doctor_profile/data/data_sources/doctor_profile_remote_data_source.dart';
import 'package:graduation_project/features/doctor_profile/data/models/doctor_profile_model.dart';
import 'package:graduation_project/features/doctor_profile/data/models/profile_image_model.dart';
import 'package:graduation_project/features/doctor_profile/data/models/public_doctor_profile_model.dart';
import 'package:graduation_project/features/doctor_profile/data/models/slot_config_model.dart';

class DoctorProfileRemoteDataSourceImpl
    implements DoctorProfileRemoteDataSource {
  final ApiService _apiService;

  DoctorProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<DoctorProfileModel> getDoctorProfile() async {
    final response = await _apiService.get('doctor/profile');
    return DoctorProfileModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<bool> updateBasicInfo(Map<String, dynamic> body) async {
    final response = await _apiService.patch(
      'doctor/profile/basic-info',
      body: body,
    );
    return response != null;
  }

  @override
  Future<bool> updateLocation(Map<String, dynamic> body) async {
    final response = await _apiService.patch(
      'doctor/profile/location',
      body: body,
    );
    return response != null;
  }

  @override
  Future<bool> replaceVerificationDocument({
    required int verificationId,
    required File newFile,
  }) async {
    final formData = FormData.fromMap({
      'newFile': await MultipartFile.fromFile(
        newFile.path,
        filename: newFile.path.split('/').last,
      ),
    });
    final response = await _apiService.putMultipart(
      'doctor/profile/verification-documents/$verificationId',
      formData,
    );
    return response != null;
  }

  @override
  Future<bool> updateAchievement({
    required int achievementId,
    Map<String, dynamic>? body,
    File? image,
  }) async {
    final formDataMap = <String, dynamic>{};

    if (body != null) {
      formDataMap.addAll(body);
    }

    if (image != null) {
      formDataMap['image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );
    }

    final response = await _apiService.patchMultipart(
      'doctor/profile/achievements/$achievementId',
      FormData.fromMap(formDataMap),
    );
    return response != null;
  }

  @override
  Future<bool> deleteAchievement(int achievementId) async {
    final response = await _apiService.delete(
      'doctor/profile/achievements/$achievementId',
    );
    return response != null;
  }

  @override
  Future<ProfileImageModel> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _apiService.putMultipart(
      'profile-image/update',
      formData,
    );

    log('Profile Image Response: $response');
    return ProfileImageModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<SlotConfigModel>> getDoctorSlotConfig(int doctorId) async {
    final response = await _apiService.get('doctors/$doctorId/slot-config');
    final List<dynamic> data = response as List;
    return data
        .map((e) => SlotConfigModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PublicDoctorProfileModel> getPublicDoctorProfile(int doctorId) async {
    final response = await _apiService.get('doctor/profile/$doctorId/public');
    return PublicDoctorProfileModel.fromJson(response as Map<String, dynamic>);
  }
}

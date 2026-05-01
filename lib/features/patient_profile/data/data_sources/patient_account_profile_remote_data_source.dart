import 'dart:io';

import 'package:graduation_project/features/doctor_profile/data/models/profile_image_model.dart';

abstract class PatientAccountProfileRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();

  Future<dynamic> updateOnboardingProfile(Map<String, dynamic> body);

  Future<ProfileImageModel> updateProfileImage(File imageFile);
}

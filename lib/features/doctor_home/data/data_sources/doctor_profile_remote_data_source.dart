import 'dart:io';
import 'package:graduation_project/features/doctor_home/data/models/location_model.dart';

import '../models/complete_profile_request_model.dart';

abstract class DoctorProfileRemoteDataSource {
  Future<bool> completeProfile(CompleteProfileRequestModel request);
  Future<bool> uploadVerificationDocument({
    required int documentType,
    required File file,
  });
  Future<bool> updateLocation(LocationModel location);
  Future<bool> addAchievement({
    required String title,
    String? description,
    File? image,
  });
  Future<Map<String, dynamic>> checkProfileStatus();
}

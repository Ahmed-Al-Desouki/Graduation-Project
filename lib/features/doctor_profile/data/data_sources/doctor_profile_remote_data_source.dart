import 'dart:io';
import 'package:graduation_project/features/doctor_profile/data/models/profile_image_model.dart';
import 'package:graduation_project/features/doctor_profile/data/models/public_doctor_profile_model.dart';
import 'package:graduation_project/features/doctor_profile/data/models/slot_config_model.dart';
import '../models/doctor_profile_model.dart';

abstract class DoctorProfileRemoteDataSource {
  Future<DoctorProfileModel> getDoctorProfile();

  Future<bool> updateBasicInfo(Map<String, dynamic> body);

  Future<bool> updateLocation(Map<String, dynamic> body);

  Future<bool> replaceVerificationDocument({
    required int verificationId,
    required File newFile,
  });

  Future<bool> updateAchievement({
    required int achievementId,
    Map<String, dynamic>? body,
    File? image,
  });

  Future<bool> deleteAchievement(int achievementId);

  Future<ProfileImageModel> updateProfileImage(File imageFile);

  Future<List<SlotConfigModel>> getDoctorSlotConfig(int doctorId);

  Future<PublicDoctorProfileModel> getPublicDoctorProfile(int doctorId);
}

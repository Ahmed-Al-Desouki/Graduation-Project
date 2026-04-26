import 'package:graduation_project/features/doctor_profile/data/models/achievement_profile_model.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/public_doctor_profile_entity.dart';
// import 'package:graduation_project/features/doctor_profile/domain/entities/review_response_entity.dart';

class PublicDoctorProfileModel extends PublicDoctorProfileEntity {
  PublicDoctorProfileModel({
    required super.doctorId,
    required super.fullName,
    super.profileImageUrl,
    required super.specialization,
    required super.yearsOfExperience,
    required super.consultationFee,
    super.bio,
    required super.averageRating,
    required super.reviewCount,
    required super.isActive,
    super.clinicAddress,
    super.clinicLatitude,
    super.clinicLongitude,
    super.hospitalName,
    // required super.reviews,
    required super.achievements,
  });

  factory PublicDoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicDoctorProfileModel(
      doctorId: json['doctorId'],
      fullName: json['fullName'],
      profileImageUrl: json['profileImageUrl'],
      specialization: json['specialization'],
      yearsOfExperience: json['yearsOfExperience'],
      consultationFee: (json['consultationFee'] as num).toDouble(),
      bio: json['bio'],
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      isActive: json['isActive'],
      clinicAddress: json['clinicAddress'],
      clinicLatitude: json['clinicLatitude']?.toDouble(),
      clinicLongitude: json['clinicLongitude']?.toDouble(),
      hospitalName: json['hospitalName'],
      // reviews: (json['reviews'] as List)
      //     .map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>))
      //     .toList(),
      achievements:
          (json['achievements'] as List)
              .map((e) => AchievementModel.fromJson(e))
              .toList(),
    );
  }
}

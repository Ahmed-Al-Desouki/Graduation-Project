import 'achievement_profile_entity.dart';
// import 'review_response_entity.dart';

class PublicDoctorProfileEntity {
  final int doctorId;
  final String fullName;
  final String? profileImageUrl;
  final String specialization;
  final int yearsOfExperience;
  final double consultationFee;
  final String? bio;
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final String? clinicAddress;
  final double? clinicLatitude;
  final double? clinicLongitude;
  final String? hospitalName;
  // final List<ReviewResponse> reviews;
  final List<AchievementProfileEntity> achievements;

  PublicDoctorProfileEntity({
    required this.doctorId,
    required this.fullName,
    this.profileImageUrl,
    required this.specialization,
    required this.yearsOfExperience,
    required this.consultationFee,
    this.bio,
    required this.averageRating,
    required this.reviewCount,
    required this.isActive,
    this.clinicAddress,
    this.clinicLatitude,
    this.clinicLongitude,
    this.hospitalName,
    // required this.reviews,
    required this.achievements,
  });
}
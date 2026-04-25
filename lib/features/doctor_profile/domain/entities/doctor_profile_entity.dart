import 'verification_document_profile_entity.dart';
import 'achievement_profile_entity.dart';

class DoctorProfileEntity {
  final int doctorId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? nationalId;
  final String specialization;
  final int yearsOfExperience;
  final double consultationFee;
  final String? bio;
  final double averageRating;
  final bool isActive;
  final bool isProfileCompleted;
  final String? clinicAddress;
  final double? clinicLatitude;
  final double? clinicLongitude;
  final String? hospitalName;
  final List<VerificationDocumentProfileEntity> verificationDocuments;
  final List<AchievementProfileEntity> achievements;

  DoctorProfileEntity({
    required this.doctorId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.nationalId,
    required this.specialization,
    required this.yearsOfExperience,
    required this.consultationFee,
    this.bio,
    required this.averageRating,
    required this.isActive,
    required this.isProfileCompleted,
    this.clinicAddress,
    this.clinicLatitude,
    this.clinicLongitude,
    this.hospitalName,
    required this.verificationDocuments,
    required this.achievements,
  });

  DoctorProfileEntity copyWith({
    int? doctorId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? nationalId,
    String? specialization,
    int? yearsOfExperience,
    double? consultationFee,
    String? bio,
    double? averageRating,
    bool? isActive,
    bool? isProfileCompleted,
    String? clinicAddress,
    double? clinicLatitude,
    double? clinicLongitude,
    String? hospitalName,
    List<VerificationDocumentProfileEntity>? verificationDocuments,
    List<AchievementProfileEntity>? achievements,
  }) {
    return DoctorProfileEntity(
      doctorId: doctorId ?? this.doctorId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      consultationFee: consultationFee ?? this.consultationFee,
      bio: bio ?? this.bio,
      averageRating: averageRating ?? this.averageRating,
      isActive: isActive ?? this.isActive,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicLatitude: clinicLatitude ?? this.clinicLatitude,
      clinicLongitude: clinicLongitude ?? this.clinicLongitude,
      hospitalName: hospitalName ?? this.hospitalName,
      verificationDocuments:
          verificationDocuments ?? this.verificationDocuments,
      achievements: achievements ?? this.achievements,
    );
  }
}

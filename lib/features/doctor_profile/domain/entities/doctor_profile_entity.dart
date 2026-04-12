import 'verification_document_profile_entity.dart';
import 'achievement_profile_entity.dart';

class DoctorProfileEntity {
  final int doctorId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? nationalId;
  final String specialization;
  final int yearsOfExperience;
  final double consultationFee;
  final String? description;
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
    this.dateOfBirth,
    this.nationalId,
    required this.specialization,
    required this.yearsOfExperience,
    required this.consultationFee,
    this.description,
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
}

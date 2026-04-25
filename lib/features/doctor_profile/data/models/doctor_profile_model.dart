import '../../domain/entities/doctor_profile_entity.dart';
import 'verification_document_profile_model.dart';
import 'achievement_profile_model.dart';

class DoctorProfileModel extends DoctorProfileEntity {
  DoctorProfileModel({
    required super.doctorId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.profileImageUrl,
    super.dateOfBirth,
    super.nationalId,
    required super.specialization,
    required super.yearsOfExperience,
    required super.consultationFee,
    super.bio,
    required super.averageRating,
    required super.isActive,
    required super.isProfileCompleted,
    super.clinicAddress,
    super.clinicLatitude,
    super.clinicLongitude,
    super.hospitalName,
    required super.verificationDocuments,
    required super.achievements,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      doctorId: json['doctorId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      nationalId: json['nationalId'],
      specialization: json['specialization'],
      yearsOfExperience: json['yearsOfExperience'],
      consultationFee: (json['consultationFee'] as num).toDouble(),
      bio: json['bio'],
      averageRating: (json['averageRating'] as num).toDouble(),
      isActive: json['isActive'],
      isProfileCompleted: json['isProfileCompleted'],
      clinicAddress: json['clinicAddress'],
      clinicLatitude: json['clinicLatitude']?.toDouble(),
      clinicLongitude: json['clinicLongitude']?.toDouble(),
      hospitalName: json['hospitalName'],
      verificationDocuments:
          (json['verificationDocuments'] as List)
              .map((e) => VerificationDocumentModel.fromJson(e))
              .toList(),
      achievements:
          (json['achievements'] as List)
              .map((e) => AchievementModel.fromJson(e))
              .toList(),
    );
  }
}

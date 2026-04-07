import '../../domain/entities/complete_profile_request_entity.dart';

class CompleteProfileRequestModel extends CompleteProfileRequestEntity {
  CompleteProfileRequestModel({
    required super.fullName,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.specialization,
    required super.yearsOfExperience,
    required super.consultationFee,
    required super.nationalId,
    super.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toUtc().toIso8601String(),
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'consultationFee': consultationFee,
      'nationalId': nationalId,
      if (bio != null) 'bio': bio, // ✅ هيضاف من الباك بعدين
    };
  }
}

import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';

class PatientAccountProfileModel extends PatientAccountProfileEntity {
  const PatientAccountProfileModel({
    required super.patientId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.profileImageUrl,
    super.dateOfBirth,
    super.gender,
    super.bloodType,
    super.height,
    super.weight,
  });

  factory PatientAccountProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientAccountProfileModel(
      patientId: (json['patientID'] ?? json['patientId'] ?? 0) as int,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      dateOfBirth: _parseDate(json['dateOfBirth']),
      gender: json['gender']?.toString(),
      bloodType: json['bloodType']?.toString(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

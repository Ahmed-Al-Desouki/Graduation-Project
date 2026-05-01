class PatientAccountProfileEntity {
  final int patientId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final double? height;
  final double? weight;

  const PatientAccountProfileEntity({
    required this.patientId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.height,
    this.weight,
  });

  PatientAccountProfileEntity copyWith({
    int? patientId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
  }) {
    return PatientAccountProfileEntity(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}

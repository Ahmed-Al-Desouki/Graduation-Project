class CompleteProfileRequestEntity {
  final String fullName;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String specialization;
  final int yearsOfExperience;
  final double consultationFee;
  final String nationalId;
  final String? bio;

  CompleteProfileRequestEntity({
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.specialization,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.nationalId,
    this.bio,
  });
}

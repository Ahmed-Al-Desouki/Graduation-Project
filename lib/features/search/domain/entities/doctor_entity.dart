class DoctorEntity {
  final int doctorId;
  final String fullName;
  final String specialization;
  final double consultationFee;
  final double averageRating;
  final int totalReviews;
  final int yearsOfExperience;
  final String? description;
  final String? profileImageUrl;
  final bool isActive;

  DoctorEntity({
    required this.doctorId,
    required this.fullName,
    required this.specialization,
    required this.consultationFee,
    required this.averageRating,
    required this.totalReviews,
    required this.yearsOfExperience,
    this.description,
    this.profileImageUrl,
    required this.isActive,
  });
}

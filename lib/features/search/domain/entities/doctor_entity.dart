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
  final String? clinicAddress;
  final double? clinicLatitude;
  final double? clinicLongitude;
  final String? hospitalName;
  final double? distanceKm;
  final String? clinicMapUrl;
  final String? directionsMapUrl;

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
    this.clinicAddress,
    this.clinicLatitude,
    this.clinicLongitude,
    this.hospitalName,
    this.distanceKm,
    this.clinicMapUrl,
    this.directionsMapUrl,
  });
}

class ReviewEntity {
  final int reviewId;
  final int patientId;
  final String patientName;
  final double rating;
  final String comment;
  final DateTime reviewDate;
  final bool isVerified;
  final String? patientImagePorfile;

  ReviewEntity({
    required this.reviewId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.isVerified,
    this.patientImagePorfile
  });
}

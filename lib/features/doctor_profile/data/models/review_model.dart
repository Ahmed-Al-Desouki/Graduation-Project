import 'package:graduation_project/features/doctor_profile/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.reviewId,
    required super.patientId,
    required super.patientName,
    required super.rating,
    required super.comment,
    required super.reviewDate,
    required super.isVerified,
    super.patientImagePorfile,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      reviewDate: DateTime.parse(json['reviewDate']),
      isVerified: json['isVerified'],
      patientImagePorfile: json['patientImagePorfile'],
    );
  }
}

import 'package:graduation_project/features/search/domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  DoctorModel({
    required super.doctorId,
    required super.fullName,
    required super.specialization,
    required super.consultationFee,
    required super.averageRating,
    required super.totalReviews,
    required super.yearsOfExperience,
    super.description,
    super.profileImageUrl,
    required super.isActive,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorId: json['doctorId'] ?? 0,
      fullName: json['fullName'] ?? '',
      specialization: json['specialization'] ?? '',
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      description: json['description'],
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'fullName': fullName,
      'specialization': specialization,
      'consultationFee': consultationFee,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'yearsOfExperience': yearsOfExperience,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }
}

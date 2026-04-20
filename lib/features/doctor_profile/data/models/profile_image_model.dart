import '../../domain/entities/profile_image_entity.dart';

class ProfileImageModel extends ProfileImageEntity {
  ProfileImageModel({
    required super.fileId,
    required super.fileUrl,
    required super.fileType,
    required super.fileSize,
    required super.uploadedAt,
    super.description,
    required super.category,
  });

  factory ProfileImageModel.fromJson(Map<String, dynamic> json) {
    return ProfileImageModel(
      fileId: json['fileID'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      description: json['description'],
      category: json['category'],
    );
  }
}

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
    final fileData = json['file'] as Map<String, dynamic>? ?? json;
    return ProfileImageModel(
      fileId: fileData['fileID'] as int,
      fileUrl: fileData['fileUrl'] as String,
      fileType: fileData['fileType'] as String,
      fileSize: fileData['fileSize'] as int,
      uploadedAt: DateTime.parse(fileData['uploadedAt'] as String),
      description: fileData['description'] as String?,
      category: fileData['category'] as String,
    );
  }
}

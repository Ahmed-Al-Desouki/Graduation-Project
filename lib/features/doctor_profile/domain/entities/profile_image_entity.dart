class ProfileImageEntity {
  final int fileId;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String? description;
  final String category;

  ProfileImageEntity({
    required this.fileId,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    this.description,
    required this.category,
  });
}

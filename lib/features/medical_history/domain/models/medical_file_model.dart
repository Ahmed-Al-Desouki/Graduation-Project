class MedicalFileModel {
  final int fileID;
  final String fileUrl;
  final String fileType;
  final String description;
  final String uploadedAt;

  MedicalFileModel({
    required this.fileID,
    required this.fileUrl,
    required this.fileType,
    required this.description,
    required this.uploadedAt,
  });

  factory MedicalFileModel.fromJson(Map<String, dynamic> json) {
    return MedicalFileModel(
      fileID: json['fileID'] ?? 0,
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      description: json['description'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'fileID': fileID,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'description': description,
      'uploadedAt': uploadedAt,
    };
  }
}

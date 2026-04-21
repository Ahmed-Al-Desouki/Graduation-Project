import '../../domain/entities/verification_document_entity.dart';

class VerificationDocumentModel extends VerificationDocumentEntity {
  VerificationDocumentModel({
    super.verificationId,
    required super.documentType,
    required super.status,
    super.fileUrl,
    super.adminNotes,
    super.file,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      verificationId: json['verificationId'],
      documentType: DocumentType.values.firstWhere(
        (e) => e.value == json['documentType'],
        orElse: () => DocumentType.other,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      fileUrl: json['fileUrl'],
      adminNotes: json['adminNotes'],
    );
  }
}

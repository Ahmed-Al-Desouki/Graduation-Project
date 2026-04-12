import '../../domain/entities/verification_document_profile_entity.dart';

class VerificationDocumentModel extends VerificationDocumentProfileEntity {
  VerificationDocumentModel({
    required super.verificationId,
    required super.documentType,
    required super.status,
    super.fileUrl,
    super.adminNotes,
    super.submittedAt,
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
      submittedAt:
          json['submittedAt'] != null
              ? DateTime.parse(json['submittedAt'])
              : null,
    );
  }
}

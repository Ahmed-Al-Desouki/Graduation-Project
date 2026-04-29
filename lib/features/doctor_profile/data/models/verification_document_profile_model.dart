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
      documentType: _parseDocumentType(json['documentType']),
      status: _parseVerificationStatus(json['status']),
      fileUrl: json['fileUrl'],
      adminNotes: json['adminNotes'],
      submittedAt:
          json['submittedAt'] != null
              ? DateTime.parse(json['submittedAt'])
              : null,
    );
  }

  static DocumentType _parseDocumentType(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'license':
          return DocumentType.license;
        case 'graduationcertificate':
          return DocumentType.graduationCertificate;
        case 'nationalid':
          return DocumentType.nationalId;
        default:
          return DocumentType.other;
      }
    }
    if (value is int) {
      return DocumentType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => DocumentType.other,
      );
    }
    return DocumentType.other;
  }

  static VerificationStatus _parseVerificationStatus(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'approved':
          return VerificationStatus.approved;
        case 'rejected':
          return VerificationStatus.rejected;
        case 'pending':
          return VerificationStatus.pending;
        default:
          return VerificationStatus.pending;
      }
    }
    if (value is int) {
      return VerificationStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => VerificationStatus.pending,
      );
    }
    return VerificationStatus.pending;
  }
}

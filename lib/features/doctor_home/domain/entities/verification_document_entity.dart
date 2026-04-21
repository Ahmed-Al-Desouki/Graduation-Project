import 'dart:io';

enum DocumentType {
  license(0),
  graduationCertificate(1),
  nationalId(2),
  other(3);

  final int value;
  const DocumentType(this.value);
}

enum VerificationStatus {
  pending(0),
  approved(1),
  rejected(2);

  final int value;
  const VerificationStatus(this.value);
}

class VerificationDocumentEntity {
  final int? verificationId;
  final DocumentType documentType;
  final VerificationStatus status;
  final String? fileUrl;
  final String? adminNotes;
  final File? file;

  VerificationDocumentEntity({
    this.verificationId,
    required this.documentType,
    required this.status,
    this.fileUrl,
    this.adminNotes,
    this.file,
  });
}

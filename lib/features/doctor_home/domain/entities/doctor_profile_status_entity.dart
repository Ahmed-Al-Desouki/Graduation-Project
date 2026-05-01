import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_verification_request_status.dart';

class DoctorProfileStatusEntity {
  final bool isActive;
  final bool isProfileCompleted;
  final DoctorVerificationRequestStatus verificationRequestStatus;
  final String? verificationAdminNotes;
  final String? verificationRejectionReason;
  final List<String> missingRequiredVerificationDocuments;

  const DoctorProfileStatusEntity({
    required this.isActive,
    required this.isProfileCompleted,
    required this.verificationRequestStatus,
    this.verificationAdminNotes,
    this.verificationRejectionReason,
    this.missingRequiredVerificationDocuments = const [],
  });

  bool get isApproved =>
      verificationRequestStatus == DoctorVerificationRequestStatus.approved;

  bool get isPending =>
      verificationRequestStatus == DoctorVerificationRequestStatus.pending;

  bool get isRejected =>
      verificationRequestStatus == DoctorVerificationRequestStatus.rejected;

  bool get isIncomplete =>
      verificationRequestStatus == DoctorVerificationRequestStatus.incomplete;
}

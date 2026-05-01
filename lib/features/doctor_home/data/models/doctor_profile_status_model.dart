import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_verification_request_status.dart';

class DoctorProfileStatusModel extends DoctorProfileStatusEntity {
  const DoctorProfileStatusModel({
    required super.isActive,
    required super.isProfileCompleted,
    required super.verificationRequestStatus,
    super.verificationAdminNotes,
    super.verificationRejectionReason,
    super.missingRequiredVerificationDocuments,
  });

  factory DoctorProfileStatusModel.fromJson(Map<String, dynamic> json) {
    final missingDocuments =
        (json['missingRequiredVerificationDocuments'] as List<dynamic>?)
            ?.map((document) => document.toString())
            .toList() ??
        const <String>[];

    return DoctorProfileStatusModel(
      isActive: json['isActive'] == true,
      isProfileCompleted: json['isProfileCompleted'] == true,
      verificationRequestStatus: parseDoctorVerificationRequestStatus(
        json['verificationRequestStatus'],
      ),
      verificationAdminNotes: json['verificationAdminNotes']?.toString(),
      verificationRejectionReason:
          json['verificationRejectionReason']?.toString(),
      missingRequiredVerificationDocuments: missingDocuments,
    );
  }

  factory DoctorProfileStatusModel.incomplete() {
    return const DoctorProfileStatusModel(
      isActive: false,
      isProfileCompleted: false,
      verificationRequestStatus: DoctorVerificationRequestStatus.incomplete,
    );
  }
}

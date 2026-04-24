enum DoctorVerificationRequestStatus {
  pending,
  rejected,
  approved,
  incomplete,
  unknown,
}

DoctorVerificationRequestStatus parseDoctorVerificationRequestStatus(
  dynamic value,
) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return DoctorVerificationRequestStatus.pending;
      case 'rejected':
        return DoctorVerificationRequestStatus.rejected;
      case 'approved':
        return DoctorVerificationRequestStatus.approved;
      case 'incomplete':
        return DoctorVerificationRequestStatus.incomplete;
    }
  }

  return DoctorVerificationRequestStatus.unknown;
}

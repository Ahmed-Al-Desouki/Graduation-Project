using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.Entities.DoctorModels
{
    public static class DoctorVerificationPolicy
    {
        public static readonly DoctorDocumentType[] RequiredDocumentTypes =
        {
            DoctorDocumentType.License,
            DoctorDocumentType.GraduationCertificate,
            DoctorDocumentType.NationalId
        };

        public static IReadOnlyList<DoctorDocumentType> GetMissingRequiredDocuments(IEnumerable<DoctorVerification> verifications)
        {
            var submittedDocumentTypes = verifications
                .Select(verification => verification.DocumentType)
                .Distinct()
                .ToHashSet();

            return RequiredDocumentTypes
                .Where(requiredType => !submittedDocumentTypes.Contains(requiredType))
                .ToList();
        }

        public static DoctorVerificationRequestStatus DetermineRequestStatus(IEnumerable<DoctorVerification> verifications)
        {
            var verificationList = verifications.ToList();
            var missingRequiredDocuments = GetMissingRequiredDocuments(verificationList);

            if (missingRequiredDocuments.Count > 0)
            {
                return DoctorVerificationRequestStatus.Incomplete;
            }

            var requiredVerifications = verificationList
                .Where(verification => RequiredDocumentTypes.Contains(verification.DocumentType))
                .ToList();

            if (requiredVerifications.Any(verification => verification.Status == VerificationStatus.Rejected))
            {
                return DoctorVerificationRequestStatus.Rejected;
            }

            if (requiredVerifications.Any(verification => verification.Status == VerificationStatus.Pending))
            {
                return DoctorVerificationRequestStatus.Pending;
            }

            return requiredVerifications.All(verification => verification.Status == VerificationStatus.Approved)
                ? DoctorVerificationRequestStatus.Approved
                : DoctorVerificationRequestStatus.Incomplete;
        }

        public static bool IsDoctorEligibleForActivation(IEnumerable<DoctorVerification> verifications)
        {
            return DetermineRequestStatus(verifications) == DoctorVerificationRequestStatus.Approved;
        }
    }
}

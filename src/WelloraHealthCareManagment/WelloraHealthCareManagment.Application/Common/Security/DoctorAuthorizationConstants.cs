namespace WelloraHealthCareManagment.Application.Common.Security
{
    public static class DoctorAuthorizationConstants
    {
        public const string DoctorAccessLevelClaimType = "doctor_access_level";
        public const string DoctorVerificationStatusClaimType = "doctor_verification_request_status";
        public const string DoctorIsActiveClaimType = "doctor_is_active";

        public const string OnboardingAccessLevel = "Onboarding";
        public const string FullAccessLevel = "Full";

        public const string DoctorOnboardingAccessPolicy = "DoctorOnboardingAccess";
        public const string ApprovedDoctorOnlyPolicy = "ApprovedDoctorOnly";
        public const string ApprovedDoctorOrAdminPolicy = "ApprovedDoctorOrAdmin";
        public const string PatientAdminOrApprovedDoctorPolicy = "PatientAdminOrApprovedDoctor";
    }
}

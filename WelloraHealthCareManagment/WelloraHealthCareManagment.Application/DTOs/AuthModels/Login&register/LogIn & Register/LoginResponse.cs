
namespace WelloraHealthCareManagment.Application.DTOs.AuthModels.Login_register.LogIn
{
    public class LoginResponse
    {
        public string? AccessToken { get; set; }
        public string? RefreshToken { get; set; }
        public string? Error { get; set; }
        public string? RestrictionType { get; set; }
        public DateTime? SuspensionEndDate { get; set; }
        public bool RequiresMfa { get; set; }
        public string? MfaToken { get; set; }

        public static LoginResponse Success(string accessToken, string refreshToken)
        {
            return new LoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken
            };
        }

        public static LoginResponse MfaRequired(string mfaToken)
        {
            return new LoginResponse
            {
                RequiresMfa = true,
                MfaToken = mfaToken,
                Error = "MFA_PENDING"
            };
        }

        public static LoginResponse Failed(string error)
        {
            return new LoginResponse
            {
                Error = error
            };
        }

        public static LoginResponse AccessDenied(
            string error,
            string restrictionType,
            DateTime? suspensionEndDate = null)
        {
            return new LoginResponse
            {
                Error = error,
                RestrictionType = restrictionType,
                SuspensionEndDate = suspensionEndDate
            };
        }
    }
}

// File: Interfaces/IAuth/IGoogleAuthService.cs
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace HealthCare_.Interfaces.IAuth
{
    public interface IGoogleAuthService
    {
        /// Handles complete Google Sign-In flow including token validation, 
        /// user creation/lookup, profile setup, and session management
        Task<(string AccessToken, string RefreshToken, string? Error)> GoogleLoginAsync(
            string idToken,
            string? requestedRole,
            string? deviceInfo,
            string? ipAddress);

        /// Validates Google ID Token and extracts user payload
        Task<GooglePayload?> ValidateGoogleTokenAsync(string idToken);
    }
}
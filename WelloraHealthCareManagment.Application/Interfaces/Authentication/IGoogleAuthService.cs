using HealthCare_.Models.DTOs.AuthModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IGoogleAuthService
    {
        /// Handle Google Sign-In flow
        Task<(string AccessToken, string RefreshToken, string? Error)> GoogleLoginAsync(
            string idToken,
            string? requestedRole,
            string? deviceInfo,
            string? ipAddress);

        /// Validate Google ID Token
        Task<GooglePayload?> ValidateGoogleTokenAsync(string idToken);
    }
}

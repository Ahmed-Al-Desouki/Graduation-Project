using HealthCare_.Models.AuthModels;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.DTOs.AuthModels.Login_register.LogIn;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IAuthCoreService
    {
        /// Register new user (Patient or Doctor)
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);

        /// Login with email and password
        Task<LoginResponse> LoginAsync(
            LoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null);

        /// External login (Google, etc.) - generate tokens for existing user
        Task<(string AccessToken, string RefreshToken, string? Error)> ExternalLoginAsync(
            ApplicationUser user,
            string? deviceInfo = null,
            string? ipAddress = null);

        /// Logout user and revoke tokens
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);
    }
}

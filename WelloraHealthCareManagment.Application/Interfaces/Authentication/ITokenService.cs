using Google.Apis.Auth.OAuth2.Requests;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.Authentication.Tokens;


namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface ITokenService
    {

        /// Generate JWT Access Token
        Task<(string AccessToken, string Jti, DateTime Expires)> GenerateJwtTokenAsync(
            ApplicationUser user,
            TimeSpan? expiry = null);


        /// Generate MFA Token (short-lived)
        Task<(string MfaToken, string Jti, DateTime Expires)> GenerateMfaTokenAsync(
            ApplicationUser user);


        /// Generate Random Refresh Token (raw)
        string GenerateRandomToken();


        /// Compute HMAC-SHA256 hash for refresh token storage
        string ComputeHmacSha256Base64(string input);


        /// Encrypt refresh token using AES
        (string EncryptedText, string Salt) EncryptAes(string plainText);


        /// Decrypt refresh token using AES
        (string PlainText, string Error) DecryptAes(string cipherTextBase64, string saltBase64);


        /// Validate JWT Token and return ClaimsPrincipal
        ClaimsPrincipal? ValidateJwtToken(string token);

        /// Extract Jti from JWT Token
        string? GetJtiFromToken(string token);
        Task<RefreshTokenResponse> RefreshTokenAsync(
            RefreshRequest request,
            string? deviceInfo = null,
            string? ipAddress = null);
    }
}

using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.AuthModels;
using System.Threading.Tasks;

namespace HealthCare_.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);

        /// <summary>
        /// Login: returns AccessToken (JWT) and Encrypted RefreshToken (to return to client).
        /// deviceInfo/ipAddress are optional and used to populate UserSession and token audit.
        /// </summary>
        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
            LoginRequest request,
            string deviceInfo = null,
            string ipAddress = null);

        /// <summary>
        /// Refresh: client sends old (possibly expired) access token and encrypted refresh token.
        /// Service will validate, rotate the refresh token and return new pair.
        /// </summary>
        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
            RefreshRequest request,
            string deviceInfo = null,
            string ipAddress = null);

        /// <summary>
        /// Logout: will revoke session and associated refresh token(s).
        /// If request.UserId is omitted, the service will extract from auth header.
        /// </summary>
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);


    }
}

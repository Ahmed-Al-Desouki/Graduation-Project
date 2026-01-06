using HealthCare_.Models.DTOs.AuthModels.Login_register;

namespace HealthCare_.Interfaces.IAuth.PKeyAndPassowrd
{
    public interface IPasskeyService
    {

        Task<(string AccessToken, string RefreshToken, string Error)> BiometricRefreshAsync(
                    BiometricLoginRequest request, string deviceInfo, string ipAddress);

        Task<(bool Success, string Error)> DisableBiometricAsync(
            DisableBiometricRequest request,
            string ipAddress);

    }
}
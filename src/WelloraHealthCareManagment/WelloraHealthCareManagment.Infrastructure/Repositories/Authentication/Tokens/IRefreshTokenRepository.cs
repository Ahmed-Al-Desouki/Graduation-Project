using HealthCare_.Models.DTOs.AuthModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens
{
    public interface IRefreshTokenRepository
    {
        Task<RefreshToken?> GetByTokenHashAsync(string tokenHash, int userId);
        Task<RefreshToken?> GetByJtiAsync(string jti, int userId);
        Task<RefreshToken> AddAsync(RefreshToken refreshToken);
        Task UpdateAsync(RefreshToken refreshToken);
        Task<int> GetActiveTokenCountByUserAsync(int userId);
        Task RevokeOldestTokenAsync(int userId);
        // for password
        Task RevokeAllUserTokensAsync(int userId);
    }
}
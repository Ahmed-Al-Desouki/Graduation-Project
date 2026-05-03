using HealthCare_.Models.DTOs.AuthModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens
{
    public interface IRevokedTokenRepository
    {
        Task<bool> IsTokenRevokedAsync(string jti);
        Task AddAsync(RevokedToken revokedToken);
        Task CleanupExpiredTokensAsync();
        /// Get all expired tokens
        Task<List<RevokedToken>> GetExpiredTokensAsync(CancellationToken cancellationToken = default);

        /// Delete multiple tokens
        Task DeleteRangeAsync(List<RevokedToken> tokens, CancellationToken cancellationToken = default);


    }
}

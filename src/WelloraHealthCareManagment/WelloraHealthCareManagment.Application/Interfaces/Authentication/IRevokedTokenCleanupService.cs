using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IRevokedTokenCleanupService
    {
        /// Clean up expired revoked tokens
        Task CleanupExpiredTokensAsync(CancellationToken cancellationToken = default);
    }
}

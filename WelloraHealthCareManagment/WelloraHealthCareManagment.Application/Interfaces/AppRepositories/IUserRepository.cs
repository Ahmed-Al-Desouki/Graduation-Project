using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IUserRepository
    {
        // Basic User Operations
        Task<ApplicationUser?> GetByEmailAsync(string email);
        Task<ApplicationUser?> GetByIdAsync(int userId);
        Task<IdentityResult> CreateUserAsync(ApplicationUser user, string password);
        Task<IdentityResult> AddToRoleAsync(ApplicationUser user, string role);
        Task<IdentityResult> UpdateUserAsync(ApplicationUser user);
        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
        Task<IList<string>> GetRolesAsync(ApplicationUser user);

        // MFA Operations
        Task<IdentityResult> AddClaimAsync(ApplicationUser user, Claim claim);
        Task<bool> IsTwoFactorEnabledAsync(int userId);
        Task<IdentityResult> SetTwoFactorEnabledAsync(int userId, bool enabled);

        // Password Reset 
        Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user);
        Task<IdentityResult> ResetPasswordAsync(ApplicationUser user, string token, string newPassword);
        Task<IdentityResult> ChangePasswordAsync(ApplicationUser user, string currentPassword, string newPassword);
        Task<bool> IsEmailConfirmedAsync(ApplicationUser user);


    }
}

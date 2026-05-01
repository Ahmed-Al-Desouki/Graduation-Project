using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.Common.Localization;
using WelloraHealthCareManagment.Application.DTOs.Settings;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class UserLanguagePreferenceService : IUserLanguagePreferenceService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IAppLocalizationService _localizationService;

        public UserLanguagePreferenceService(
            UserManager<ApplicationUser> userManager,
            IAppLocalizationService localizationService)
        {
            _userManager = userManager;
            _localizationService = localizationService;
        }

        public async Task<ServiceResult<LanguagePreferenceResponse>> GetCurrentAsync(int userId, CancellationToken ct = default)
        {
            var language = await _userManager.Users
                .AsNoTracking()
                .Where(u => u.Id == userId)
                .Select(u => u.PreferredLanguage)
                .FirstOrDefaultAsync(ct);

            if (language is null)
            {
                return ServiceResult<LanguagePreferenceResponse>.Failure(_localizationService.Localize("Common.UserNotFound"));
            }

            return ServiceResult<LanguagePreferenceResponse>.Success(BuildResponse(language));
        }

        public async Task<ServiceResult<LanguagePreferenceResponse>> UpdateCurrentAsync(int userId, UpdateLanguagePreferenceRequest request, CancellationToken ct = default)
        {
            if (!AppLanguages.IsSupported(request.Language))
            {
                return ServiceResult<LanguagePreferenceResponse>.Failure(_localizationService.Localize("Language.SupportedOnly"));
            }

            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.Id == userId, ct);
            if (user is null)
            {
                return ServiceResult<LanguagePreferenceResponse>.Failure(_localizationService.Localize("Common.UserNotFound"));
            }

            user.PreferredLanguage = AppLanguages.Normalize(request.Language);

            var updateResult = await _userManager.UpdateAsync(user);
            if (!updateResult.Succeeded)
            {
                var errorMessage = updateResult.Errors.FirstOrDefault()?.Description
                    ?? "Failed to update language preference.";

                return ServiceResult<LanguagePreferenceResponse>.Failure(errorMessage);
            }

            return ServiceResult<LanguagePreferenceResponse>.Success(BuildResponse(user.PreferredLanguage));
        }

        private static LanguagePreferenceResponse BuildResponse(string language)
        {
            var normalized = AppLanguages.Normalize(language);

            return new LanguagePreferenceResponse
            {
                Language = normalized,
                IsRightToLeft = AppLanguages.IsRtl(normalized),
                SupportedLanguages = AppLanguages.Supported
            };
        }
    }
}

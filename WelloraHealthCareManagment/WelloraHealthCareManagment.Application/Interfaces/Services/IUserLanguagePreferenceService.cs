using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Settings;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IUserLanguagePreferenceService
    {
        Task<ServiceResult<LanguagePreferenceResponse>> GetCurrentAsync(int userId, CancellationToken ct = default);
        Task<ServiceResult<LanguagePreferenceResponse>> UpdateCurrentAsync(int userId, UpdateLanguagePreferenceRequest request, CancellationToken ct = default);
    }
}

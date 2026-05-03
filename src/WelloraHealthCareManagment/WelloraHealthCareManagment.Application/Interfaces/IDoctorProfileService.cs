using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos;

namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface IDoctorProfileService
    {
        // ─── Profile ───
        Task<ServiceResult<DoctorProfileResponse>> GetProfileAsync(int doctorId);
        Task<ServiceResult<PublicDoctorProfileResponse>> GetPublicProfileAsync(int doctorId);
        Task<ServiceResult> CompleteDoctorProfileAsync(int doctorId, CompleteDoctorProfileRequest request);

        // ─── Partial Updates ───
        Task<ServiceResult> UpdateBasicInfoAsync(int doctorId, UpdateDoctorBasicInfoRequest request);
        Task<ServiceResult> UpdateLocationAsync(int doctorId, UpdateDoctorLocationRequest request);

        // ─── Verification Documents ───
        Task<ServiceResult> AddVerificationDocumentAsync(int doctorId, AddVerificationDocumentRequest request);
        Task<ServiceResult> ReplaceVerificationDocumentAsync(int doctorId, int verificationId, IFormFile newFile);

        // ─── Achievements ───
        Task<ServiceResult<AchievementResponse>> AddAchievementAsync(int doctorId, AddAchievementRequest request);
        Task<ServiceResult> UpdateAchievementAsync(int doctorId, int achievementId, UpdateAchievementRequest request);
        Task<ServiceResult> DeleteAchievementAsync(int doctorId, int achievementId);
    }
}

using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.PatientDot;

namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface IPatientProfileService
    {
        Task<ServiceResult<PatientProfileResponse>> GetProfileAsync(int patientId);
        Task<ServiceResult<PatientProfileResponse>> UpdateOnboardingAsync(
            int patientId,
            PatientOnboardingRequest request);
        Task<ServiceResult<PatientProfileResponse>> UpdateBasicInfoAsync(
            int patientId,
            UpdatePatientBasicInfoRequest request);
    }
}

// Application/Interfaces/Services/IDoctorVerificationService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IDoctorVerificationService
    {
        // Admin: Get pending verifications
        Task<ServiceResult<DoctorVerificationListResponse>> GetPendingVerificationsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        // Admin: Get all verifications with filtering
        Task<ServiceResult<DoctorVerificationListResponse>> GetAllVerificationsAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        // Admin: Get doctor verification request details
        Task<ServiceResult<DoctorVerificationDoctorDto>> GetDoctorVerificationDetailsAsync(
            int doctorId,
            CancellationToken ct = default);

        // Admin: Approve doctor
        Task<ServiceResult> ApproveDoctorAsync(
            int doctorId,
            ApproveDoctorVerificationRequest? request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default);

        // Admin: Reject doctor (permanent)
        Task<ServiceResult> RejectDoctorAsync(
            int doctorId,
            RejectDoctorVerificationRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default);

        // Check if doctor is verified (used by middleware)
        Task<bool> IsDoctorVerifiedAsync(int doctorId, CancellationToken ct = default);
        Task<ServiceResult<VerificationStatus?>> GetDoctorVerificationStatusAsync(
            int doctorId,
            CancellationToken ct = default);

        // Statistics
        Task<ServiceResult<VerificationStatisticsDto>> GetStatisticsAsync(CancellationToken ct = default);
    }
}

// Application/Interfaces/AppRepositories/IDoctorVerificationRepository.cs
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IDoctorVerificationRepository
    {
        Task<DoctorVerification> CreateAsync(DoctorVerification verification, CancellationToken ct = default);
        Task UpdateAsync(DoctorVerification verification, CancellationToken ct = default);
        Task<DoctorVerification?> GetByIdAsync(int verificationId, CancellationToken ct = default);
        Task<DoctorVerification?> GetByIdWithDoctorAsync(int verificationId, CancellationToken ct = default);

        // Doctor's verification history
        Task<List<DoctorVerification>> GetByDoctorIdAsync(
            int doctorId,
            CancellationToken ct = default);

        // Get active (latest) verification for a doctor
        Task<DoctorVerification?> GetLatestByDoctorIdAsync(
            int doctorId,
            CancellationToken ct = default);

        // Check if doctor is verified
        Task<bool> IsDoctorVerifiedAsync(int doctorId, CancellationToken ct = default);
        Task<VerificationStatus?> GetDoctorVerificationStatusAsync(
            int doctorId,
            CancellationToken ct = default);

        // Admin queries - pending verifications
        Task<List<DoctorVerification>> GetPendingVerificationsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task<int> CountPendingVerificationsAsync(CancellationToken ct = default);

        // All verifications with filtering
        Task<List<DoctorVerification>> GetAllAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task<int> CountAllAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);

        // Statistics
        Task<Dictionary<VerificationStatus, int>> GetStatusCountsAsync(CancellationToken ct = default);
        Task<bool> ExistsAsync(int doctorId, DoctorDocumentType type);

        // ─── Methods for Admin Dashboard ───
        Task<int> CountVerifiedDoctorsAsync(CancellationToken ct = default);
        Task<double?> GetAverageDoctorRatingAsync(CancellationToken ct = default);
        Task<int> GetTotalReviewsCountAsync(CancellationToken ct = default);
        Task<int> CountApprovedThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default);
        Task<int> CountRejectedThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default);
        Task<int> CountApprovedBetweenAsync(DateTime startDate, DateTime endDate, CancellationToken ct = default);

        // For Recent Activity
        Task<List<DoctorVerificationDto>> GetRecentPendingVerificationsAsync(int count = 5, CancellationToken ct = default);

    }
}

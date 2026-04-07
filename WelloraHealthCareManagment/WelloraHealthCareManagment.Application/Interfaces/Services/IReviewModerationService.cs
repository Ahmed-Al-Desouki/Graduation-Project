// Application/Interfaces/Services/IReviewModerationService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Enums;


namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IReviewModerationService
    {
        // Admin: Get all reviews (active)
        Task<ServiceResult<ReviewListResponse>> GetAllReviewsAsync(
            int? doctorId = null,
            int? userId = null,
            double? minRating = null,
            double? maxRating = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        // Admin: Get deleted reviews
        Task<ServiceResult<ReviewListResponse>> GetDeletedReviewsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        // Admin: Delete review (soft delete)
        Task<ServiceResult> DeleteReviewAsync(
            DeleteReviewRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default);

        // Admin: Restore review
        Task<ServiceResult> RestoreReviewAsync(
            RestoreReviewRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default);

        // Admin: Get review details
        Task<ServiceResult<ReviewModerationDto>> GetReviewDetailsAsync(
            int reviewId,
            CancellationToken ct = default);

        // Recalculate doctor's average rating after review deletion/restoration
        Task RecalculateDoctorRatingAsync(int doctorId, CancellationToken ct = default);


    }
}
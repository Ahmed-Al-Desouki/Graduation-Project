using HealthCare_.Models.sharedModels.Reviews;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IReviewRepository
    {
        Task<Review> CreateAsync(Review review);
        Task UpdateAsync(Review review);
        Task DeleteAsync(Review review);
        Task<Review?> GetByIdAsync(int reviewId);

        // للتحقق من ownership عند update/delete
        Task<Review?> GetByIdAndPatientAsync(int reviewId, int patientId);
        Task<Review?> GetActiveByPatientAndDoctorAsync(int patientId, int doctorId);

        // لعرض reviews الدكتور في GET /profile
        Task<List<Review>> GetByDoctorIdAsync(int doctorId);

        // لحساب متوسط التقييم
        Task<double> GetAverageRatingForDoctorAsync(int doctorId);

        // لإحصائيات الأدمن
        Task<int> GetReviewCountForDoctorAsync(int doctorId);

        // Soft delete methods
        Task SoftDeleteAsync(Review review, int adminId, string? reason, CancellationToken ct = default);
        Task RestoreAsync(Review review, CancellationToken ct = default);

        // Query non-deleted reviews
        Task<List<Review>> GetByDoctorIdActiveAsync(int doctorId, CancellationToken ct = default);
        Task<double> GetAverageRatingForDoctorActiveAsync(int doctorId, CancellationToken ct = default);
        Task<int> GetReviewCountForDoctorActiveAsync(int doctorId, CancellationToken ct = default);

        // Admin: Get deleted reviews
        Task<List<Review>> GetDeletedReviewsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task<int> CountDeletedReviewsAsync(CancellationToken ct = default);

        Task<List<Review>> GetAllReviewsFilteredAsync(
        int? doctorId = null,
        int? userId = null,
        double? minRating = null,
        double? maxRating = null,
        DateTime? fromDate = null,
        DateTime? toDate = null,
        int page = 1,
        int pageSize = 10,
        CancellationToken ct = default);

        Task<int> CountAllReviewsFilteredAsync(
            int? doctorId = null,
            int? userId = null,
            double? minRating = null,
            double? maxRating = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);

        Task<Dictionary<int, string>> GetDoctorNamesByIdsAsync(List<int> doctorIds, CancellationToken ct = default);
        Task<Review?> GetByIdWithDeletedByAdminAsync(int reviewId, CancellationToken ct = default);
    }
}

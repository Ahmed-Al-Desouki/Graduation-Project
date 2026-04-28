using HealthCare_.Models.sharedModels.Reviews;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly HealthCarePlusContext _context;

        public ReviewRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Review> CreateAsync(Review review)
        {
            await _context.Reviews.AddAsync(review);
            await _context.SaveChangesAsync();
            return review;
        }

        public async Task UpdateAsync(Review review)
        {
            _context.Reviews.Update(review);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Review review)
        {
            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();
        }

        public async Task<Review?> GetByIdAsync(int reviewId)
        {
            return await _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .FirstOrDefaultAsync(r => r.ReviewID == reviewId);
        }

        public async Task<Review?> GetByIdAndPatientAsync(int reviewId, int patientId)
        {
            return await _context.Reviews
                .FirstOrDefaultAsync(r =>
                    r.ReviewID == reviewId &&
                    r.UserID == patientId);
        }

        public async Task<Review?> GetActiveByPatientAndDoctorAsync(int patientId, int doctorId)
        {
            return await _context.Reviews
                .AsNoTracking()
                .FirstOrDefaultAsync(r =>
                    r.UserID == patientId &&
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId &&
                    !r.IsDeleted);
        }

        public async Task<List<Review>> GetByDoctorIdAsync(int doctorId)
        {
            return await _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .AsNoTracking()
                .Where(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId)
                .OrderByDescending(r => r.ReviewDate)
                .ToListAsync();
        }

        public async Task<double> GetAverageRatingForDoctorAsync(int doctorId)
        {
            var reviews = await _context.Reviews
                .AsNoTracking()
                .Where(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId)
                .ToListAsync();

            if (!reviews.Any()) return 0;

            return Math.Round(reviews.Average(r => r.Rating), 2);
        }

        public async Task<int> GetReviewCountForDoctorAsync(int doctorId)
        {
            return await _context.Reviews
                .AsNoTracking()
                .CountAsync(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId);
        }
        public async Task SoftDeleteAsync(Review review, int adminId, string? reason, CancellationToken ct = default)
        {
            review.IsDeleted = true;
            review.DeletedAt = DateTime.UtcNow;
            review.DeletedByAdminId = adminId;
            review.DeletionReason = reason;
            review.UpdatedAt = DateTime.UtcNow;

            _context.Reviews.Update(review);
            await _context.SaveChangesAsync(ct);
        }

        public async Task RestoreAsync(Review review, CancellationToken ct = default)
        {
            review.IsDeleted = false;
            review.DeletedAt = null;
            review.DeletedByAdminId = null;
            review.DeletionReason = null;
            review.UpdatedAt = DateTime.UtcNow;

            _context.Reviews.Update(review);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<List<Review>> GetByDoctorIdActiveAsync(int doctorId, CancellationToken ct = default)
        {
            return await _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .AsNoTracking()
                .Where(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId &&
                    !r.IsDeleted)
                .OrderByDescending(r => r.ReviewDate)
                .ToListAsync(ct);
        }

        public async Task<double> GetAverageRatingForDoctorActiveAsync(int doctorId, CancellationToken ct = default)
        {
            var reviews = await _context.Reviews
                .AsNoTracking()
                .Where(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId &&
                    !r.IsDeleted)
                .ToListAsync(ct);

            if (!reviews.Any()) return 0;

            return Math.Round(reviews.Average(r => r.Rating), 2);
        }

        public async Task<int> GetReviewCountForDoctorActiveAsync(int doctorId, CancellationToken ct = default)
        {
            return await _context.Reviews
                .AsNoTracking()
                .CountAsync(r =>
                    r.TargetType == "Doctor" &&
                    r.TargetID == doctorId &&
                    !r.IsDeleted, ct);
        }

        public async Task<List<Review>> GetDeletedReviewsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            return await _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .Include(r => r.DeletedByAdmin)
                .Where(r => r.IsDeleted)
                .OrderByDescending(r => r.DeletedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountDeletedReviewsAsync(CancellationToken ct = default)
        {
            return await _context.Reviews
                .CountAsync(r => r.IsDeleted, ct);
        }
        public async Task<List<Review>> GetAllReviewsFilteredAsync(
            int? doctorId = null,
            int? userId = null,
            double? minRating = null,
            double? maxRating = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            var query = _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .Include(r => r.DeletedByAdmin)
                .Where(r => !r.IsDeleted)
                .AsQueryable();

            if (doctorId.HasValue)
                query = query.Where(r => r.TargetType == "Doctor" && r.TargetID == doctorId.Value);

            if (userId.HasValue)
                query = query.Where(r => r.UserID == userId.Value);

            if (minRating.HasValue)
                query = query.Where(r => r.Rating >= minRating.Value);

            if (maxRating.HasValue)
                query = query.Where(r => r.Rating <= maxRating.Value);

            if (fromDate.HasValue)
                query = query.Where(r => r.ReviewDate >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(r => r.ReviewDate <= toDate.Value);

            return await query
                .OrderByDescending(r => r.ReviewDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllReviewsFilteredAsync(
            int? doctorId = null,
            int? userId = null,
            double? minRating = null,
            double? maxRating = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.Reviews
                .Where(r => !r.IsDeleted)
                .AsQueryable();

            if (doctorId.HasValue)
                query = query.Where(r => r.TargetType == "Doctor" && r.TargetID == doctorId.Value);

            if (userId.HasValue)
                query = query.Where(r => r.UserID == userId.Value);

            if (minRating.HasValue)
                query = query.Where(r => r.Rating >= minRating.Value);

            if (maxRating.HasValue)
                query = query.Where(r => r.Rating <= maxRating.Value);

            if (fromDate.HasValue)
                query = query.Where(r => r.ReviewDate >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(r => r.ReviewDate <= toDate.Value);

            return await query.CountAsync(ct);
        }

        public async Task<Dictionary<int, string>> GetDoctorNamesByIdsAsync(
            List<int> doctorIds,
            CancellationToken ct = default)
        {
            if (doctorIds == null || !doctorIds.Any())
                return new Dictionary<int, string>();

            return await _context.Doctors
                .Include(d => d.User)
                .Where(d => doctorIds.Contains(d.DoctorId))
                .AsNoTracking()
                .ToDictionaryAsync(
                    d => d.DoctorId,
                    d => d.User.FullName ?? "Unknown Doctor",
                    ct);
        }
        public async Task<Review?> GetByIdWithDeletedByAdminAsync(int reviewId, CancellationToken ct = default)
        {
            return await _context.Reviews
                .Include(r => r.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .Include(r => r.DeletedByAdmin)
                .FirstOrDefaultAsync(r => r.ReviewID == reviewId, ct);
        }
    }
}


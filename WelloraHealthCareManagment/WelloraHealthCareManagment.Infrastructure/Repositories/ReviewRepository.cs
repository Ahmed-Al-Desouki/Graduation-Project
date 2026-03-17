using HealthCare_.Models.sharedModels.Reviews;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
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
                .FirstOrDefaultAsync(r => r.ReviewID == reviewId);
        }

        public async Task<Review?> GetByIdAndPatientAsync(int reviewId, int patientId)
        {
            return await _context.Reviews
                .FirstOrDefaultAsync(r =>
                    r.ReviewID == reviewId &&
                    r.UserID == patientId);
        }

        public async Task<List<Review>> GetByDoctorIdAsync(int doctorId)
        {
            return await _context.Reviews
                .Include(r => r.User)
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
    }
}

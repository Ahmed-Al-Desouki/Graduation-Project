// Infrastructure/Repositories/DoctorVerificationRepository.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class DoctorVerificationRepository : IDoctorVerificationRepository
    {
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<DoctorVerificationRepository> _logger;

        public DoctorVerificationRepository(HealthCarePlusContext context,ILogger<DoctorVerificationRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<DoctorVerification> CreateAsync(DoctorVerification verification, CancellationToken ct = default)
        {
            await _context.DoctorVerifications.AddAsync(verification, ct);
            await _context.SaveChangesAsync(ct);
            return verification;
        }

        public async Task UpdateAsync(DoctorVerification verification, CancellationToken ct = default)
        {
            _context.DoctorVerifications.Update(verification);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<DoctorVerification?> GetByIdAsync(int verificationId, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.File)
                .FirstOrDefaultAsync(dv => dv.VerificationId == verificationId, ct);
        }

        public async Task<DoctorVerification?> GetByIdWithDoctorAsync(int verificationId, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.Doctor)
                    .ThenInclude(d => d.User)
                .Include(dv => dv.File)
                .FirstOrDefaultAsync(dv => dv.VerificationId == verificationId, ct);
        }

        public async Task<List<DoctorVerification>> GetByDoctorIdAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.File)
                .Where(dv => dv.DoctorId == doctorId)
                .OrderByDescending(dv => dv.SubmittedAt)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<DoctorVerification?> GetLatestByDoctorIdAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.File)
                .Where(dv => dv.DoctorId == doctorId)
                .OrderByDescending(dv => dv.SubmittedAt)
                .FirstOrDefaultAsync(ct);
        }

        public async Task<bool> IsDoctorVerifiedAsync(int doctorId, CancellationToken ct = default)
        {
            var latestVerification = await GetLatestByDoctorIdAsync(doctorId, ct);
            return latestVerification?.Status == VerificationStatus.Approved;
        }

        public async Task<VerificationStatus?> GetDoctorVerificationStatusAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            var latestVerification = await _context.DoctorVerifications
                .Where(dv => dv.DoctorId == doctorId)
                .OrderByDescending(dv => dv.SubmittedAt)
                .Select(dv => dv.Status)
                .FirstOrDefaultAsync(ct);

            return latestVerification == default ? null : latestVerification;
        }

        //public async Task<List<DoctorVerification>> GetPendingVerificationsAsync(
        //    int page = 1,
        //    int pageSize = 10,
        //    CancellationToken ct = default)
        //{
        //    return await _context.DoctorVerifications
        //        .Include(dv => dv.Doctor)
        //            .ThenInclude(d => d.User)
        //        .Include(dv => dv.File)
        //        .Where(dv => dv.Status == VerificationStatus.Pending)
        //        .OrderBy(dv => dv.SubmittedAt) // FIFO - oldest first
        //        .Skip((page - 1) * pageSize)
        //        .Take(pageSize)
        //        .AsNoTracking()
        //        .ToListAsync(ct);
        //}
        public async Task<List<DoctorVerification>> GetPendingVerificationsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.Doctor)
                    .ThenInclude(d => d.User)
                .Include(dv => dv.File)
                .Where(dv => dv.Status == VerificationStatus.Pending)
                .OrderBy(dv => dv.SubmittedAt)     
                .ThenBy(dv => dv.VerificationId)             
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsSplitQuery()                     // مهم جداً مع Includes + Pagination
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountPendingVerificationsAsync(CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .CountAsync(dv => dv.Status == VerificationStatus.Pending, ct);
        }

        public async Task<List<DoctorVerification>> GetAllAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            var query = _context.DoctorVerifications
                .Include(dv => dv.Doctor)
                .ThenInclude(d => d.User)
                .Include(dv => dv.File)
                .AsQueryable();

            if (status.HasValue)
                query = query.Where(dv => dv.Status == status.Value);

            if (fromDate.HasValue)
                query = query.Where(dv => dv.SubmittedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(dv => dv.SubmittedAt <= toDate.Value);

            return await query
                .OrderByDescending(dv => dv.SubmittedAt)
                .ThenBy(dv => dv.VerificationId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.DoctorVerifications.AsQueryable();

            if (status.HasValue)
                query = query.Where(dv => dv.Status == status.Value);

            if (fromDate.HasValue)
                query = query.Where(dv => dv.SubmittedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(dv => dv.SubmittedAt <= toDate.Value);

            return await query.CountAsync(ct);
        }

        //public async Task<Dictionary<VerificationStatus, int>> GetStatusCountsAsync(CancellationToken ct = default)
        //{
        //    return await _context.DoctorVerifications
        //        .GroupBy(dv => dv.Status)
        //        .Select(g => new { Status = g.Key, Count = g.Count() })
        //        .ToDictionaryAsync(x => x.Status, x => x.Count, ct);
        //}
        public async Task<Dictionary<VerificationStatus, int>> GetStatusCountsAsync(CancellationToken ct = default)
        {
            try
            {
                var statusGroups = await _context.DoctorVerifications
                    .GroupBy(dv => dv.Status)
                    .Select(g => new { Status = g.Key, Count = g.Count() })
                    .ToListAsync(ct);

                var dictionary = new Dictionary<VerificationStatus, int>();

                foreach (var item in statusGroups)
                {
                    if (dictionary.ContainsKey(item.Status))
                    {
                        // لو المفتاح موجود، اجمع العدد
                        dictionary[item.Status] += item.Count;
                    }
                    else
                    {
                        // لو المفتاح مش موجود، أضفه
                        dictionary[item.Status] = item.Count;
                    }
                }

                return dictionary;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting verification status counts");
                return new Dictionary<VerificationStatus, int>();
            }
        }
        public async Task<bool> ExistsAsync(int doctorId, DoctorDocumentType type)
        {
            return await _context.DoctorVerifications
                .AnyAsync(v => v.DoctorId == doctorId && v.DocumentType == type);
        }


        // الدوال للـ Dashboard
        public async Task<int> CountVerifiedDoctorsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors.CountAsync(d => d.IsActive, ct);
        }

        public async Task<double?> GetAverageDoctorRatingAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .Where(d => d.IsActive && d.AverageRating > 0)
                .AverageAsync(d => (double?)d.AverageRating, ct);
        }

        public async Task<int> GetTotalReviewsCountAsync(CancellationToken ct = default)
        {
            return await _context.Reviews
                .CountAsync(r => r.TargetType == "Doctor" && !r.IsDeleted, ct);
        }

        public async Task<int> CountApprovedThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .CountAsync(dv => dv.Status == VerificationStatus.Approved &&
                                  dv.ReviewedAt.HasValue &&
                                  dv.ReviewedAt.Value >= startOfMonth, ct);
        }

        public async Task<int> CountRejectedThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .CountAsync(dv => dv.Status == VerificationStatus.Rejected &&
                                  dv.ReviewedAt.HasValue &&
                                  dv.ReviewedAt.Value >= startOfMonth, ct);
        }

        public async Task<List<DoctorVerificationDto>> GetRecentPendingVerificationsAsync(int count = 5, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.Doctor)
                    .ThenInclude(d => d.User)
                .Where(dv => dv.Status == VerificationStatus.Pending)
                .OrderBy(dv => dv.SubmittedAt)
                .Take(count)
                .AsNoTracking()
                .Select(dv => new DoctorVerificationDto
                {
                    VerificationId = dv.VerificationId,
                    DoctorId = dv.DoctorId,
                    DoctorName = dv.Doctor.User.FullName,
                    DoctorEmail = dv.Doctor.User.Email ?? string.Empty,
                    Specialization = dv.Doctor.Specialization,
                    DocumentType = dv.DocumentType,
                    Status = dv.Status,
                    SubmittedAt = dv.SubmittedAt
                })
                .ToListAsync(ct);
        }
    }
}
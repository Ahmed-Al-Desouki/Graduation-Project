// Infrastructure/Repositories/DoctorVerificationRepository.cs
using HealthCare_.Models.DoctorModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Infrastructure.Context;
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

        //public async Task UpdateAsync(DoctorVerification verification, CancellationToken ct = default)
        //{
        //    _context.DoctorVerifications.Update(verification);
        //    await _context.SaveChangesAsync(ct);
        //}
        public async Task UpdateAsync(DoctorVerification verification, CancellationToken ct = default)
        {
            var existing = await _context.DoctorVerifications
                .FirstOrDefaultAsync(v => v.VerificationId == verification.VerificationId, ct);

            if (existing == null)
                return;

            existing.Status = verification.Status;
            existing.ReviewedByAdminId = verification.ReviewedByAdminId;
            existing.ReviewedAt = verification.ReviewedAt;
            existing.AdminNotes = verification.AdminNotes;
            existing.RejectionReason = verification.RejectionReason;
            existing.UpdatedAt = verification.UpdatedAt;
            existing.FileId = verification.FileId;
            existing.SubmittedAt = verification.SubmittedAt;
            existing.DocumentType = verification.DocumentType;
            existing.DoctorId = verification.DoctorId;

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
                .Include(dv => dv.ReviewedByAdmin)
                .FirstOrDefaultAsync(dv => dv.VerificationId == verificationId, ct);
        }

        public async Task<List<DoctorVerification>> GetByDoctorIdAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Include(dv => dv.File)
                .Include(dv => dv.ReviewedByAdmin)
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
            var verifications = await _context.DoctorVerifications
                .Where(dv => dv.DoctorId == doctorId)
                .AsNoTracking()
                .ToListAsync(ct);

            return DoctorVerificationPolicy.IsDoctorEligibleForActivation(verifications);
        }

        public async Task<VerificationStatus?> GetDoctorVerificationStatusAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            var verifications = await _context.DoctorVerifications
                .Where(dv => dv.DoctorId == doctorId)
                .AsNoTracking()
                .ToListAsync(ct);

            if (verifications.Count == 0)
            {
                return null;
            }

            return DoctorVerificationPolicy.DetermineRequestStatus(verifications) switch
            {
                DoctorVerificationRequestStatus.Approved => VerificationStatus.Approved,
                DoctorVerificationRequestStatus.Rejected => VerificationStatus.Rejected,
                _ => VerificationStatus.Pending
            };
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

        //public async Task<List<Doctor>> GetPendingDoctorsWithVerificationsAsync(
        //    int page = 1,
        //    int pageSize = 10,
        //    CancellationToken ct = default)
        //{
        //    return await _context.Doctors
        //        .Where(d =>
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.License) &&
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.GraduationCertificate) &&
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.NationalId) &&
        //            (
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.License && v.Status == VerificationStatus.Pending) ||
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.GraduationCertificate && v.Status == VerificationStatus.Pending) ||
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.NationalId && v.Status == VerificationStatus.Pending)
        //            ) &&
        //            !d.Verifications.Any(v =>
        //                (v.DocumentType == DoctorDocumentType.License ||
        //                 v.DocumentType == DoctorDocumentType.GraduationCertificate ||
        //                 v.DocumentType == DoctorDocumentType.NationalId) &&
        //                v.Status == VerificationStatus.Rejected))
        //        .OrderBy(d => d.Verifications
        //            .Where(v =>
        //                (v.DocumentType == DoctorDocumentType.License ||
        //                 v.DocumentType == DoctorDocumentType.GraduationCertificate ||
        //                 v.DocumentType == DoctorDocumentType.NationalId) &&
        //                v.Status == VerificationStatus.Pending)
        //            .Min(v => v.SubmittedAt))
        //        .ThenBy(d => d.DoctorId)
        //        .Skip((page - 1) * pageSize)
        //        .Take(pageSize)
        //        .Include(d => d.User)
        //        .Include(d => d.Verifications)
        //            .ThenInclude(v => v.File)
        //        .Include(d => d.Verifications)
        //            .ThenInclude(v => v.ReviewedByAdmin)
        //        .AsSplitQuery()
        //        .AsNoTracking()
        //        .ToListAsync(ct);
        //}

        //public async Task<int> CountPendingDoctorsAsync(CancellationToken ct = default)
        //{
        //    return await _context.Doctors
        //        .CountAsync(d =>
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.License) &&
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.GraduationCertificate) &&
        //            d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.NationalId) &&
        //            (
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.License && v.Status == VerificationStatus.Pending) ||
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.GraduationCertificate && v.Status == VerificationStatus.Pending) ||
        //                d.Verifications.Any(v => v.DocumentType == DoctorDocumentType.NationalId && v.Status == VerificationStatus.Pending)
        //            ) &&
        //            !d.Verifications.Any(v =>
        //                (v.DocumentType == DoctorDocumentType.License ||
        //                 v.DocumentType == DoctorDocumentType.GraduationCertificate ||
        //                 v.DocumentType == DoctorDocumentType.NationalId) &&
        //                v.Status == VerificationStatus.Rejected), ct);
        //}
        public async Task<List<Doctor>> GetPendingDoctorsWithVerificationsAsync(
    int page = 1,
    int pageSize = 10,
    CancellationToken ct = default)
        {
            var requiredTypes = new[]
            {
        DoctorDocumentType.License,
        DoctorDocumentType.GraduationCertificate,
        DoctorDocumentType.NationalId
    };

            // الخطوة 1: جيب IDs بس من الـ DB (query بسيطة)
            var verifications = await _context.DoctorVerifications
                .Where(v => requiredTypes.Contains(v.DocumentType))
                .Select(v => new { v.DoctorId, v.DocumentType, v.Status, v.SubmittedAt })
                .AsNoTracking()
                .ToListAsync(ct);

            // الخطوة 2: الـ filtering والـ sorting في الـ memory
            var qualifyingIds = verifications
                .GroupBy(v => v.DoctorId)
                .Where(g =>
                    requiredTypes.All(t => g.Any(v => v.DocumentType == t)) &&
                    g.Any(v => v.Status == VerificationStatus.Pending) &&
                    !g.Any(v => v.Status == VerificationStatus.Rejected)
                )
                .OrderBy(g => g
                    .Where(v => v.Status == VerificationStatus.Pending)
                    .Min(v => v.SubmittedAt))
                .ThenBy(g => g.Key)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(g => g.Key)
                .ToList();

            if (!qualifyingIds.Any())
                return new List<Doctor>();

            // الخطوة 3: جيب بيانات الـ Doctors الكاملة بـ IDs بسيطة
            return await _context.Doctors
                .Where(d => qualifyingIds.Contains(d.DoctorId))
                .Include(d => d.User)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.File)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.ReviewedByAdmin)
                .AsSplitQuery()
                .AsNoTracking()
                .ToListAsync(ct);
        }
        public async Task<int> CountPendingDoctorsAsync(CancellationToken ct = default)
        {
            var requiredTypes = new[]
            {
        DoctorDocumentType.License,
        DoctorDocumentType.GraduationCertificate,
        DoctorDocumentType.NationalId
    };

            // جيب بس الـ columns اللي محتاجها - مفيش Includes أو joins
            var verifications = await _context.DoctorVerifications
                .Where(v => requiredTypes.Contains(v.DocumentType))
                .Select(v => new { v.DoctorId, v.DocumentType, v.Status })
                .AsNoTracking()
                .ToListAsync(ct);

            // عمل الـ filtering في الـ memory بدل SQL
            return verifications
                .GroupBy(v => v.DoctorId)
                .Count(g =>
                    requiredTypes.All(t => g.Any(v => v.DocumentType == t)) &&   // عنده الـ 3 documents
                    g.Any(v => v.Status == VerificationStatus.Pending) &&         // في pending
                    !g.Any(v => v.Status == VerificationStatus.Rejected)          // مفيش rejected
                );
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

        //public async Task<List<Doctor>> GetDoctorsWithVerificationsAsync(
        //    VerificationStatus? status = null,
        //    DateTime? fromDate = null,
        //    DateTime? toDate = null,
        //    int page = 1,
        //    int pageSize = 10,
        //    CancellationToken ct = default)
        //{
        //    var doctorsQuery = _context.Doctors
        //        .Where(d => d.Verifications.Any(dv =>
        //            (!status.HasValue || dv.Status == status.Value) &&
        //            (!fromDate.HasValue || dv.SubmittedAt >= fromDate.Value) &&
        //            (!toDate.HasValue || dv.SubmittedAt <= toDate.Value)));

        //    return await doctorsQuery
        //        .OrderByDescending(d => d.Verifications
        //            .Where(dv =>
        //                (!status.HasValue || dv.Status == status.Value) &&
        //                (!fromDate.HasValue || dv.SubmittedAt >= fromDate.Value) &&
        //                (!toDate.HasValue || dv.SubmittedAt <= toDate.Value))
        //            .Max(dv => dv.SubmittedAt))
        //        .ThenBy(d => d.DoctorId)
        //        .Skip((page - 1) * pageSize)
        //        .Take(pageSize)
        //        .Include(d => d.User)
        //        .Include(d => d.Verifications)
        //            .ThenInclude(v => v.File)
        //        .Include(d => d.Verifications)
        //            .ThenInclude(v => v.ReviewedByAdmin)
        //        .AsSplitQuery()
        //        .AsNoTracking()
        //        .ToListAsync(ct);
        //}
        public async Task<List<Doctor>> GetDoctorsWithVerificationsAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            var filteredDoctorsQuery = _context.Doctors
                .Where(d => d.Verifications.Any(dv =>
                    (!status.HasValue || dv.Status == status.Value) &&
                    (!fromDate.HasValue || dv.SubmittedAt >= fromDate.Value) &&
                    (!toDate.HasValue || dv.SubmittedAt <= toDate.Value)));

            var doctorIds = await filteredDoctorsQuery
                .OrderByDescending(d => d.Verifications
                    .Where(dv =>
                        (!status.HasValue || dv.Status == status.Value) &&
                        (!fromDate.HasValue || dv.SubmittedAt >= fromDate.Value) &&
                        (!toDate.HasValue || dv.SubmittedAt <= toDate.Value))
                    .Max(dv => dv.SubmittedAt))
                .ThenBy(d => d.DoctorId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(d => d.DoctorId)
                .ToListAsync(ct);

            if (doctorIds.Count == 0)
                return new List<Doctor>();

            var doctors = await _context.Doctors
                .Where(d => doctorIds.Contains(d.DoctorId))
                .Include(d => d.User)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.File)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.ReviewedByAdmin)
                .AsSplitQuery()
                .AsNoTracking()
                .ToListAsync(ct);

            return doctors
                .OrderBy(d => doctorIds.IndexOf(d.DoctorId))
                .ToList();
        }

        public async Task<List<Doctor>> GetAllDoctorsWithVerificationsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .Include(d => d.User)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.File)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.ReviewedByAdmin)
                .AsSplitQuery()
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountDoctorsAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            return await _context.Doctors
                .CountAsync(d => d.Verifications.Any(dv =>
                    (!status.HasValue || dv.Status == status.Value) &&
                    (!fromDate.HasValue || dv.SubmittedAt >= fromDate.Value) &&
                    (!toDate.HasValue || dv.SubmittedAt <= toDate.Value)), ct);
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

        public async Task<int> CountApprovedBetweenAsync(DateTime startDate, DateTime endDate, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .CountAsync(dv => dv.Status == VerificationStatus.Approved &&
                                  dv.ReviewedAt.HasValue &&
                                  dv.ReviewedAt.Value >= startDate &&
                                  dv.ReviewedAt.Value < endDate, ct);
        }

        public async Task<int> CountPendingDoctorRequestsBetweenAsync(DateTime startDate, DateTime endDate, CancellationToken ct = default)
        {
            return await _context.DoctorVerifications
                .Where(dv => dv.SubmittedAt >= startDate &&
                             dv.SubmittedAt < endDate &&
                             dv.Status == VerificationStatus.Pending)
                .Select(dv => dv.DoctorId)
                .Distinct()
                .CountAsync(ct);
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


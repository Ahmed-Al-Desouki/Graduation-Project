using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo
{
    public class DoctorVerificationRepository : IDoctorVerificationRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorVerificationRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<DoctorVerification> CreateAsync(DoctorVerification verification)
        {
            await _context.DoctorVerifications.AddAsync(verification);
            await _context.SaveChangesAsync();
            return verification;
        }

        public async Task UpdateAsync(DoctorVerification verification)
        {
            _context.DoctorVerifications.Update(verification);
            await _context.SaveChangesAsync();
        }

        public async Task<DoctorVerification?> GetByIdAsync(int verificationId)
        {
            return await _context.DoctorVerifications
                .Include(v => v.File)
                .FirstOrDefaultAsync(v => v.VerificationId == verificationId);
        }

        public async Task<DoctorVerification?> GetByDoctorAndTypeAsync(int doctorId, DoctorDocumentType type)
        {
            return await _context.DoctorVerifications
                .Include(v => v.File)
                .FirstOrDefaultAsync(v => v.DoctorId == doctorId && v.DocumentType == type);
        }

        public async Task<List<DoctorVerification>> GetByDoctorIdAsync(int doctorId)
        {
            return await _context.DoctorVerifications
                .Include(v => v.File)
                .Where(v => v.DoctorId == doctorId)
                .OrderByDescending(v => v.SubmittedAt)
                .ToListAsync();
        }

        public async Task<bool> ExistsAsync(int doctorId, DoctorDocumentType type)
        {
            return await _context.DoctorVerifications
                .AnyAsync(v => v.DoctorId == doctorId && v.DocumentType == type);
        }
    }
}

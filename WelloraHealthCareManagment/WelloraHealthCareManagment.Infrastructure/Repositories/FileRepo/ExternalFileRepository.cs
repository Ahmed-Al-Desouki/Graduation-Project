using AutoMapper;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo
{
    public class ExternalFileRepository : IExternalFileRepository
    {
        private readonly HealthCarePlusContext _context;

        public ExternalFileRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<ExternalFile> CreateAsync(ExternalFile file)
        {
            await _context.ExternalFiles.AddAsync(file);
            await _context.SaveChangesAsync();
            return file;
        }

        public async Task<ExternalFile?> GetByIdAsync(int fileId)
        {
            return await _context.ExternalFiles.FindAsync(fileId);
        }

        public async Task<List<ExternalFile>> GetByPatientIdAsync(int patientId)
        {
            return await _context.ExternalFiles
                .Where(f => f.PatientID == patientId && f.CategoryType == "Patient")
                .OrderByDescending(f => f.UploadedAt)
                .ToListAsync();
        }

        public async Task<List<ExternalFile>> GetByDoctorIdAsync(int doctorId)
        {
            return await _context.ExternalFiles
                .Where(f => f.DoctorID == doctorId && f.CategoryType == "Doctor")
                .OrderByDescending(f => f.UploadedAt)
                .ToListAsync();
        }
        public async Task<ExternalFile> GetDoctorURLProfile(int doctorId)
        {
            return await _context.ExternalFiles
                .Where(f => f.DoctorID == doctorId
                         && f.CategoryType == "Doctor"
                         && f.CategoryValue == "Profile")
                .OrderByDescending(f => f.UploadedAt)
                .FirstOrDefaultAsync();    
        }

        public async Task DeleteAsync(ExternalFile file)
        {
            _context.ExternalFiles.Remove(file);
            await _context.SaveChangesAsync();
        }


        /// Get patient file with ownership verification
        public async Task<ExternalFile?> GetPatientFileByIdAsync(int fileId, int patientId)
        {
            return await _context.ExternalFiles
                .FirstOrDefaultAsync(f =>
                    f.FileID == fileId &&
                    f.PatientID == patientId);
        }

        /// Get doctor file with ownership verification
        public async Task<ExternalFile?> GetDoctorFileByIdAsync(int fileId, int doctorId)
        {
            return await _context.ExternalFiles
                .FirstOrDefaultAsync(f =>
                    f.FileID == fileId &&
                    f.DoctorID == doctorId);
        }

        public async Task<List<ExternalFile>> GetPatientFilesByCategoryAsync(int patientId, string categoryType)
        {
            return await _context.ExternalFiles
                .Where(f =>
                    f.PatientID == patientId &&
                    f.CategoryType == categoryType)
                .OrderByDescending(f => f.UploadedAt)
                .ToListAsync();
        }

        public async Task<List<ExternalFile>> GetDoctorFilesByCategoryAsync(int doctorId, string categoryType)
        {
            return await _context.ExternalFiles
                .Where(f =>
                    f.DoctorID == doctorId &&
                    f.CategoryType == categoryType)
                .OrderByDescending(f => f.UploadedAt)
                .ToListAsync();
        }

        public async Task<List<ExternalFile>> GetProfileFilesForUserAsync(int userId, string role)
        {
            var normalizedRole = role?.Trim();
            var profileSources = new[] { "Profile", "GoogleProfile" };

            var query = _context.ExternalFiles
                .Where(f =>
                    profileSources.Contains(f.CategoryValue ?? string.Empty) ||
                    f.CategoryType == "Profile");

            if (string.Equals(normalizedRole, "Doctor", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(f =>
                    f.DoctorID == userId ||
                    (f.PatientID == userId && f.DoctorID == null && f.CategoryValue == "GoogleProfile"));
            }
            else
            {
                query = query.Where(f => f.PatientID == userId);
            }

            return await query
                .OrderByDescending(f => f.UploadedAt)
                .ThenByDescending(f => f.FileID)
                .ToListAsync();
        }

        public async Task UpdateAsync(ExternalFile file)
        {
            _context.ExternalFiles.Update(file);
            await _context.SaveChangesAsync();
        }
    }
}

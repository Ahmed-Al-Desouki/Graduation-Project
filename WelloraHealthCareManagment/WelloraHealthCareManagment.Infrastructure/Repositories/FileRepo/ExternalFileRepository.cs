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
        public async Task UpdateAsync(ExternalFile file)
        {
            _context.ExternalFiles.Update(file);
            await _context.SaveChangesAsync();
        }
    }
}
// Infrastructure/Repositories/MedicalFileRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
{
    public class MedicalFileRepository : IMedicalFileRepository
    {
        private readonly HealthCarePlusContext _context;

        public MedicalFileRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<ExternalFile>> GetLabTestsByHistoryIdAsync(int historyId)
        {
            return await _context.ExternalFiles
                .AsNoTracking()
                .Where(f => f.MedicalHistoryID == historyId && f.CategoryValue == "LabTest")
                .ToListAsync();
        }

        public async Task<List<ExternalFile>> GetRadiologyFilesByHistoryIdAsync(int historyId)
        {
            return await _context.ExternalFiles
                .AsNoTracking()
                .Where(f => f.MedicalHistoryID == historyId && f.CategoryValue == "Radiology")
                .ToListAsync();
        }
    }
}

// Infrastructure/Repositories/SurgeryRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class SurgeryRepository : ISurgeryRepository
    {
        private readonly HealthCarePlusContext _context;

        public SurgeryRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<Surgery>> GetByHistoryIdAsync(int historyId)
        {
            return await _context.Surgeries
                .AsNoTracking()
                .Where(s => s.HistoryID == historyId && !s.IsDeleted)
                .ToListAsync();
        }

        public async Task<Surgery?> GetByIdAsync(int surgeryId, int historyId)
        {
            return await _context.Surgeries
                .FirstOrDefaultAsync(s =>
                    s.SurgeryID == surgeryId &&
                    s.HistoryID == historyId &&
                    !s.IsDeleted);
        }

        public async Task<Surgery> AddAsync(Surgery surgery)
        {
            _context.Surgeries.Add(surgery);
            await _context.SaveChangesAsync();
            return surgery;
        }

        public async Task UpdateAsync(Surgery surgery)
        {
            _context.Surgeries.Update(surgery);
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteAsync(Surgery surgery)
        {
            _context.Surgeries.Update(surgery);
            await _context.SaveChangesAsync();
        }
    }
}

// Infrastructure/Repositories/FamilyHistoryRepository.cs

using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
{
    public class FamilyHistoryRepository : IFamilyHistoryRepository
    {
        private readonly HealthCarePlusContext _context;

        public FamilyHistoryRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<FamilyHistoryEntry>> GetByHistoryIdAsync(int historyId)
        {
            return await _context.FamilyHistoryEntries
                .AsNoTracking()
                .Where(f => f.HistoryID == historyId && !f.IsDeleted)
                .ToListAsync();
        }

        public async Task<FamilyHistoryEntry?> GetByIdAsync(int familyHistoryId, int historyId)
        {
            return await _context.FamilyHistoryEntries
                .FirstOrDefaultAsync(f =>
                    f.FamilyHistoryID == familyHistoryId &&
                    f.HistoryID == historyId &&
                    !f.IsDeleted);
        }

        public async Task<FamilyHistoryEntry> AddAsync(FamilyHistoryEntry entry)
        {
            _context.FamilyHistoryEntries.Add(entry);
            await _context.SaveChangesAsync();
            return entry;
        }

        public async Task UpdateAsync(FamilyHistoryEntry entry)
        {
            _context.FamilyHistoryEntries.Update(entry);
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteAsync(FamilyHistoryEntry entry)
        {
            _context.FamilyHistoryEntries.Update(entry);
            await _context.SaveChangesAsync();
        }
    }
}

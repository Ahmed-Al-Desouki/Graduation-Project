// Infrastructure/Repositories/SocialHistoryRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Repositories;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
{
    public class SocialHistoryRepository : ISocialHistoryRepository
    {
        private readonly HealthCarePlusContext _context;

        public SocialHistoryRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<SocialHistory>> GetByHistoryIdAsync(int historyId)
        {
            return await _context.SocialHistories
                .AsNoTracking()
                .Where(s => s.HistoryID == historyId && !s.IsDeleted)
                .ToListAsync();
        }

        public async Task<SocialHistory?> GetSingleByHistoryIdAsync(int historyId)
        {
            return await _context.SocialHistories
                .FirstOrDefaultAsync(s => s.HistoryID == historyId && !s.IsDeleted);
        }

        public async Task<SocialHistory?> GetByIdAsync(int socialHistoryId, int historyId)
        {
            return await _context.SocialHistories
                .FirstOrDefaultAsync(s =>
                    s.SocialHistoryID == socialHistoryId &&
                    s.HistoryID == historyId &&
                    !s.IsDeleted);
        }

        public async Task<SocialHistory> AddAsync(SocialHistory socialHistory)
        {
            _context.SocialHistories.Add(socialHistory);
            await _context.SaveChangesAsync();
            return socialHistory;
        }

        public async Task UpdateAsync(SocialHistory socialHistory)
        {
            _context.SocialHistories.Update(socialHistory);
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteAsync(SocialHistory socialHistory)
        {
            _context.SocialHistories.Update(socialHistory);
            await _context.SaveChangesAsync();
        }
    }
}

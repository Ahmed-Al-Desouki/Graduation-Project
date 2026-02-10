using HealthCare_.Models.V2;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.ReminderRepo
{
    public class ReminderRepository : IReminderRepository
    {
        private readonly HealthCarePlusContext _context;

        public ReminderRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<ReminderV2?> GetByIdAsync(int reminderId, int patientId)
        {
            return await _context.ReminderV2s
                .AsNoTracking()
                //.Include(r => r.PrescriptionMed)
                .FirstOrDefaultAsync(r => r.Id == reminderId && r.PatientId == patientId);
        }

        public async Task<List<ReminderV2>> GetAllByPatientIdAsync(int patientId)
        {
            return await _context.ReminderV2s
                .AsNoTracking()
                .Where(r => r.PatientId == patientId)
                .ToListAsync();
        }

        public async Task<List<ReminderV2>> GetActiveByPatientIdAsync(int patientId)
        {
            return await _context.ReminderV2s
                .AsNoTracking()
                //.Include(r => r.PrescriptionMed)
                .Where(r => r.PatientId == patientId && r.IsActive)
                .ToListAsync();
        }

        public async Task<ReminderV2> AddAsync(ReminderV2 reminder)
        {
            _context.ReminderV2s.Add(reminder);
            await _context.SaveChangesAsync();
            return reminder;
        }

        public async Task UpdateAsync(ReminderV2 reminder)
        {
            _context.ReminderV2s.Update(reminder);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(ReminderV2 reminder)
        {
            _context.ReminderV2s.Remove(reminder);
            await _context.SaveChangesAsync();
        }

        public async Task<List<int>> GetAllActivePatientIdsAsync()
        {
            return await _context.ReminderV2s
                .Where(r => r.IsActive)
                .Select(r => r.PatientId)
                .Distinct()
                .ToListAsync();
        }
    }
}

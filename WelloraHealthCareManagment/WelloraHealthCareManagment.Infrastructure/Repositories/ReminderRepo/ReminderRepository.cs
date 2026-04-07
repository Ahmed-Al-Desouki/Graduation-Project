using HealthCare_.Models.V2;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.ReminderRepo
{
    public class ReminderRepository : IReminderRepository
    {
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<ReminderRepository> _logger;

        public ReminderRepository(HealthCarePlusContext context,ILogger<ReminderRepository> logger)
        {
            _context = context;
            _logger = logger;
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
                .Where(r => r.PatientId == patientId && r.IsActive == true)
                .ToListAsync();
        }

        public async Task<List<ReminderV2>> GetActiveByPatientIdAsync(int patientId)
        {
            return await _context.ReminderV2s
                .AsNoTracking()
                .Where(r => r.PatientId == patientId && r.IsActive)
                .Include(r => r.PrescriptionItem)
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
                .Where(r => r.IsActive && r.PatientId.HasValue)
                .Select(r => r.PatientId.Value)
                .Distinct()
                .ToListAsync();
        }

        public async Task<List<ReminderV2>> GetActiveByDoctorIdAsync(int doctorId)
        {
            return await _context.ReminderV2s
                .Where(r => r.DoctorId == doctorId && r.IsActive)
                .ToListAsync();
        }
        public async Task<List<int>> GetAllActiveDoctorIdsAsync()
        {
            return await _context.ReminderV2s
                .Where(r => r.IsActive && r.DoctorId.HasValue)
                .Select(r => r.DoctorId.Value)
                .Distinct()
                .ToListAsync();
        }

        public async Task<List<ReminderV2>> GetByAppointmentIdAsync(Guid appointmentId)
        {
            return await _context.ReminderV2s
                .Where(r => r.AppointmentId == appointmentId)
                .ToListAsync();
        }

        public async Task<IList<ReminderV2>> GetAllExpiredActiveRemindersAsync(DateTime asOfUtc)
        {
            return await _context.ReminderV2s
                .Where(r => r.EndDateUtc.HasValue && r.EndDateUtc.Value < asOfUtc)
                .ToListAsync();
        }
        public async Task HardDeleteAsync(int reminderId)
        {
            var reminder = await _context.ReminderV2s
                .FirstOrDefaultAsync(r => r.Id == reminderId);

            if (reminder is null)
            {
                _logger.LogWarning(
                    "HardDeleteAsync called for Reminder {ReminderId} but it was not found — skipping",
                    reminderId);
                return;
            }

            _context.ReminderV2s.Remove(reminder);
            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Hard deleted Reminder {ReminderId} from database", reminderId);
        }
    }
}

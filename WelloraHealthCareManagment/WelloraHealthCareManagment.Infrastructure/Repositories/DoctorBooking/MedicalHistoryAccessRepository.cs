using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class MedicalHistoryAccessRepository : IMedicalHistoryAccessRepository
    {
        private readonly HealthCarePlusContext _context;

        public MedicalHistoryAccessRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<MedicalHistoryAccessGrant?> GetActiveGrantAsync(
            int patientId,
            int doctorId,
            Guid? appointmentId = null,
            CancellationToken cancellationToken = default)
        {
            var now = DateTime.UtcNow;

            var query = _context.MedicalHistoryAccessGrants
                .Where(g => g.PatientId == patientId
                    && g.DoctorId == doctorId
                    && g.RevokedAt == null
                    && (g.ExpiresAt == null || g.ExpiresAt > now));

            if (appointmentId.HasValue)
                query = query.Where(g => g.AppointmentId == appointmentId.Value);

            return await query.FirstOrDefaultAsync(cancellationToken);
        }

        public async Task<List<MedicalHistoryAccessGrant>> GetPatientGrantsAsync(
            int patientId,
            bool activeOnly = true,
            CancellationToken cancellationToken = default)
        {
            var query = _context.MedicalHistoryAccessGrants
                .Include(g => g.Doctor)
                .Where(g => g.PatientId == patientId);

            if (activeOnly)
            {
                var now = DateTime.UtcNow;
                query = query.Where(g => g.RevokedAt == null
                    && (g.ExpiresAt == null || g.ExpiresAt > now));
            }

            return await query
                .OrderByDescending(g => g.GrantedAt)
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            MedicalHistoryAccessGrant grant,
            CancellationToken cancellationToken = default)
        {
            await _context.MedicalHistoryAccessGrants.AddAsync(grant, cancellationToken);
        }

        public async Task AddLogAsync(
            MedicalHistoryAccessLog log,
            CancellationToken cancellationToken = default)
        {
            await _context.MedicalHistoryAccessLogs.AddAsync(log, cancellationToken);
        }
    }
}
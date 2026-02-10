using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class DoctorScheduleRepository : IDoctorScheduleRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorScheduleRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<DoctorScheduleTemplate?> GetActiveTemplateAsync(
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            var now = DateTime.UtcNow.Date;

            return await _context.DoctorScheduleTemplates
                .Include(t => t.TimeRanges)
                .Where(t => t.DoctorId == doctorId
                    && t.IsActive
                    && t.EffectiveFromDate <= now
                    && (t.EffectiveToDate == null || t.EffectiveToDate >= now))
                .OrderByDescending(t => t.EffectiveFromDate)
                .FirstOrDefaultAsync(cancellationToken);
        }

        public async Task<DoctorScheduleTemplate?> GetByIdWithDetailsAsync(
            Guid templateId,
            CancellationToken cancellationToken = default)
        {
            return await _context.DoctorScheduleTemplates
                .Include(t => t.TimeRanges)
                .FirstOrDefaultAsync(t => t.Id == templateId, cancellationToken);
        }

        public async Task<List<DoctorScheduleTemplate>> GetActiveTemplatesAsync(
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            return await _context.DoctorScheduleTemplates
                .Include(t => t.TimeRanges)
                .Where(t => t.DoctorId == doctorId && t.IsActive)
                .OrderByDescending(t => t.EffectiveFromDate)
                .ToListAsync(cancellationToken);
        }

        public async Task<List<int>> GetDoctorsWithActiveSchedulesAsync(
            CancellationToken cancellationToken = default)
        {
            var now = DateTime.UtcNow.Date;

            return await _context.DoctorScheduleTemplates
                .Where(t => t.IsActive
                    && t.EffectiveFromDate <= now
                    && (t.EffectiveToDate == null || t.EffectiveToDate >= now))
                .Select(t => t.DoctorId)
                .Distinct()
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            DoctorScheduleTemplate template,
            CancellationToken cancellationToken = default)
        {
            await _context.DoctorScheduleTemplates.AddAsync(template, cancellationToken);
        }

        public async Task UpdateAsync(
            DoctorScheduleTemplate template,
            CancellationToken cancellationToken = default)
        {
            _context.DoctorScheduleTemplates.Update(template);
            await Task.CompletedTask;
        }
    }
}
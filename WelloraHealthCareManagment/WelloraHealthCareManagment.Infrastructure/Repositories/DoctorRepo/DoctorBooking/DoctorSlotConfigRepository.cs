using Microsoft.EntityFrameworkCore;
using System;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Repositories
{
    public class DoctorSlotConfigRepository : IDoctorSlotConfigRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorSlotConfigRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<DoctorSlotConfig?> GetByDoctorAndDayAsync(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct = default)
            => await _context.DoctorSlotConfigs
                .FirstOrDefaultAsync(c =>
                    c.DoctorId == doctorId &&
                    c.DayOfWeek == day, ct);

        public async Task<List<DoctorSlotConfig>> GetActiveConfigsAsync(
            int doctorId,
            CancellationToken ct = default)
            => await _context.DoctorSlotConfigs
                .Where(c => c.DoctorId == doctorId && c.IsActive)
                .OrderBy(c => c.DayOfWeek)
                .ToListAsync(ct);

        public async Task<List<DoctorSlotConfig>> GetAllConfigsAsync(
            int doctorId,
            CancellationToken ct = default)
            => await _context.DoctorSlotConfigs
                .Where(c => c.DoctorId == doctorId)
                .OrderBy(c => c.DayOfWeek)
                .ToListAsync(ct);

        public async Task<List<int>> GetDoctorsWithActiveConfigsAsync(
            CancellationToken ct = default)
            => await _context.DoctorSlotConfigs
                .Where(c => c.IsActive)
                .Select(c => c.DoctorId)
                .Distinct()
                .ToListAsync(ct);

        public async Task AddAsync(
            DoctorSlotConfig config,
            CancellationToken ct = default)
            => await _context.DoctorSlotConfigs.AddAsync(config, ct);

        public Task UpdateAsync(
            DoctorSlotConfig config,
            CancellationToken ct = default)
        {
            _context.DoctorSlotConfigs.Update(config);
            return Task.CompletedTask;
        }

        public Task DeleteAsync(
            DoctorSlotConfig config,
            CancellationToken ct = default)
        {
            _context.DoctorSlotConfigs.Remove(config);
            return Task.CompletedTask;
        }
    }
}
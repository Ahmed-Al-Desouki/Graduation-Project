using Microsoft.EntityFrameworkCore;
using System;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    public class TimeSlotRepository : ITimeSlotRepository
    {
        private readonly HealthCarePlusContext _context;

        public TimeSlotRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<TimeSlot?> GetByIdAsync(
            Guid slotId, CancellationToken ct = default)
            => await _context.TimeSlots.FindAsync(new object[] { slotId }, ct);

        public async Task<TimeSlot?> GetByIdWithDoctorAsync(
            Guid slotId, CancellationToken ct = default)
            => await _context.TimeSlots
                .Include(s => s.Doctor)
                .FirstOrDefaultAsync(s => s.Id == slotId, ct);

        public async Task<List<TimeSlot>> GetAvailableSlotsAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken ct = default)
            => await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.Status == SlotStatus.Available &&
                    s.SlotDate.Date >= startDate.Date &&
                    s.SlotDate.Date <= endDate.Date)
                .OrderBy(s => s.SlotDate)
                .ThenBy(s => s.StartTime)
                .ToListAsync(ct);

        public async Task<bool> ExistsAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            CancellationToken ct = default)
            => await _context.TimeSlots
                .AnyAsync(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate.Date == slotDate.Date &&
                    s.StartTime == startTime &&
                    s.Status != SlotStatus.Cancelled, ct);

        /// <summary>
        /// interval overlap: start < existingEnd AND end > existingStart
        /// بيشيل الـ Cancelled من الحسبة
        /// excludeSlotId مفيدة لما تعمل update لـ slot موجودة
        /// </summary>
        public async Task<bool> HasOverlapAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime,
            Guid? excludeSlotId = null,
            CancellationToken ct = default)
        {
            var query = _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate.Date == slotDate.Date &&
                    s.Status != SlotStatus.Cancelled &&
                    s.StartTime < endTime &&
                    s.EndTime > startTime);

            if (excludeSlotId.HasValue)
                query = query.Where(s => s.Id != excludeSlotId.Value);

            return await query.AnyAsync(ct);
        }

        public async Task<List<TimeSlot>> GetExistingSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken ct = default)
            => await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate.Date == date.Date)
                .ToListAsync(ct);

        public async Task AddAsync(TimeSlot slot, CancellationToken ct = default)
            => await _context.TimeSlots.AddAsync(slot, ct);

        public async Task AddRangeAsync(
            List<TimeSlot> slots, CancellationToken ct = default)
            => await _context.TimeSlots.AddRangeAsync(slots, ct);

        public Task UpdateAsync(TimeSlot slot, CancellationToken ct = default)
        {
            _context.TimeSlots.Update(slot);
            return Task.CompletedTask;
        }

        public Task DeleteAsync(TimeSlot slot, CancellationToken ct = default)
        {
            _context.TimeSlots.Remove(slot);
            return Task.CompletedTask;
        }

        public Task DeleteRangeAsync(
            List<TimeSlot> slots, CancellationToken ct = default)
        {
            _context.TimeSlots.RemoveRange(slots);
            return Task.CompletedTask;
        }

        public async Task<List<TimeSlot>> GetSlotsInDateRangeAsync(
            int doctorId,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken ct = default)
            => await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate.Date >= fromDate.Date &&
                    s.SlotDate.Date <= toDate.Date)
                .Include(s => s.Appointment)
                    .ThenInclude(a => a.Patient)      
                        .ThenInclude(p => p.User) 
                .OrderBy(s => s.SlotDate)
                .ThenBy(s => s.StartTime)
                .ToListAsync(ct);

        public async Task<List<TimeSlot>> GetAvailableAndBookedSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken ct = default)
            => await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate.Date == date.Date &&
                    (s.Status == SlotStatus.Available || s.Status == SlotStatus.Booked))
                .OrderBy(s => s.StartTime)
                .ToListAsync(ct);

        public async Task<List<TimeSlot>> GetSlotsForDatesAsync(
            int doctorId,
            List<DateTime> dates,
            CancellationToken ct = default)
        {
            var normalizedDates = dates.Select(d => d.Date).ToList();
            return await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    normalizedDates.Contains(s.SlotDate.Date))
                .ToListAsync(ct);
        }

        public async Task<DateTime?> GetLastSlotDateAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            var lastDate = await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.Status != SlotStatus.Cancelled)
                .MaxAsync(s => (DateTime?)s.SlotDate, ct);

            return lastDate;
        }

        public async Task<List<TimeSlot>> GetSlotsForDaysInRangeAsync(
            int doctorId,
            List<DayOfWeek> days,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken ct = default)
        {
            // ✅ جيب كل الـ slots في الـ range الأول بـ SQL عادي
            // ثم فلتر بالـ DayOfWeek في الـ memory — أضمن حل مع EF Core
            var allInRange = await _context.TimeSlots
                .Where(s =>
                    s.DoctorId == doctorId &&
                    s.SlotDate >= fromDate.Date &&
                    s.SlotDate <= toDate.Date)
                .OrderBy(s => s.SlotDate)
                .ThenBy(s => s.StartTime)
                .ToListAsync(ct);

            return allInRange
                .Where(s => days.Contains(s.SlotDate.DayOfWeek))
                .ToList();
        }
    }
}
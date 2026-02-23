using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class TimeSlotRepository : ITimeSlotRepository
    {
        private readonly HealthCarePlusContext _context;

        public TimeSlotRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<TimeSlot?> GetByIdAsync(
            Guid slotId,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Include(s => s.Doctor)
                .FirstOrDefaultAsync(s => s.Id == slotId, cancellationToken);
        }

        public async Task<TimeSlot?> GetByIdWithDoctorAsync(
            Guid slotId,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Include(s => s.Doctor)           
                    .ThenInclude(d => d.User)   
                .FirstOrDefaultAsync(s => s.Id == slotId, cancellationToken);
        }

        public async Task<List<TimeSlot>> GetAvailableSlotsAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Where(s => s.DoctorId == doctorId
                    && s.SlotDate >= startDate.Date
                    && s.SlotDate <= endDate.Date
                    && s.Status == SlotStatus.Available)
                .OrderBy(s => s.SlotDate)
                .ThenBy(s => s.StartTime)
                .AsNoTracking() // أسرع للقراءة فقط
                .ToListAsync(cancellationToken);
        }

        public async Task<bool> ExistsAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .AnyAsync(s => s.DoctorId == doctorId
                    && s.SlotDate == slotDate.Date
                    && s.StartTime == startTime,
                    cancellationToken);
        }

        public async Task<List<TimeSlot>> GetExistingSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Where(s => s.DoctorId == doctorId && s.SlotDate == date.Date)
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            TimeSlot slot,
            CancellationToken cancellationToken = default)
        {
            await _context.TimeSlots.AddAsync(slot, cancellationToken);
        }

        public async Task AddRangeAsync(
            List<TimeSlot> slots,
            CancellationToken cancellationToken = default)
        {
            // استخدام BulkInsert للسرعة
            await _context.TimeSlots.AddRangeAsync(slots, cancellationToken);
        }

        public async Task UpdateAsync(
            TimeSlot slot,
            CancellationToken cancellationToken = default)
        {
            _context.TimeSlots.Update(slot);
            await Task.CompletedTask;
        }

        public async Task DeleteAsync(
            TimeSlot slot,
            CancellationToken cancellationToken = default)
        {
            _context.TimeSlots.Remove(slot);
            await Task.CompletedTask;
        }

        public async Task DeleteRangeAsync(
            List<TimeSlot> slots,
            CancellationToken cancellationToken = default)
        {
            _context.TimeSlots.RemoveRange(slots);
            await Task.CompletedTask;
        }

        public async Task<List<TimeSlot>> GetSlotsInDateRangeAsync(
            int doctorId,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Where(s => s.DoctorId == doctorId
                         && s.SlotDate >= fromDate
                         && s.SlotDate <= toDate)
                .Include(s => s.Appointment)              
                    .ThenInclude(a => a.Patient)
                        .ThenInclude(p => p.User)      
                .OrderBy(s => s.SlotDate)
                .ThenBy(s => s.StartTime)
                .ToListAsync(cancellationToken);
        }
        public async Task<List<TimeSlot>> GetAvailableAndBookedSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default)
        {
            return await _context.TimeSlots
                .Where(s => s.DoctorId == doctorId
                    && s.SlotDate.Date == date.Date
                    && (s.Status == SlotStatus.Available || s.Status == SlotStatus.Booked))
                .ToListAsync(cancellationToken);
        }
    }
}
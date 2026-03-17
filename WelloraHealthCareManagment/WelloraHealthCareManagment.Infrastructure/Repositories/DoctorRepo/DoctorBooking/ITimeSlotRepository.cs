using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    public interface ITimeSlotRepository
    {
        Task<TimeSlot?> GetByIdAsync(Guid slotId, CancellationToken cancellationToken = default);

        Task<TimeSlot?> GetByIdWithDoctorAsync(Guid slotId, CancellationToken cancellationToken = default);

        Task<List<TimeSlot>> GetAvailableSlotsAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default);

        Task<bool> ExistsAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            CancellationToken cancellationToken = default);

        Task<List<TimeSlot>> GetExistingSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default);

        Task AddAsync(TimeSlot slot, CancellationToken cancellationToken = default);
        Task AddRangeAsync(List<TimeSlot> slots, CancellationToken cancellationToken = default);
        Task UpdateAsync(TimeSlot slot, CancellationToken cancellationToken = default);
        Task DeleteAsync(TimeSlot slot, CancellationToken cancellationToken = default);
        Task DeleteRangeAsync(List<TimeSlot> slots, CancellationToken cancellationToken = default);
        Task<List<TimeSlot>> GetSlotsInDateRangeAsync(
            int doctorId,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken cancellationToken = default);
        Task<List<TimeSlot>> GetAvailableAndBookedSlotsForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default);

        // Get all slots for multiple dates (for batch processing)
        Task<List<TimeSlot>> GetSlotsForDatesAsync(
            int doctorId,
            List<DateTime> dates,
            CancellationToken cancellationToken = default);

        // Get last slot date for doctor (للـ rolling window)
        Task<DateTime?> GetLastSlotDateAsync(
            int doctorId,
            CancellationToken cancellationToken = default);

        Task<List<TimeSlot>> GetSlotsForDaysInRangeAsync(
            int doctorId,
            List<DayOfWeek> days,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken cancellationToken = default);
    }
}
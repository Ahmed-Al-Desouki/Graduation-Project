using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IDoctorSlotConfigService
    {
        // ── Config Management ──
        Task SetDayConfigAsync(
            int doctorId,
            SetDayConfigRequest request,
            CancellationToken ct = default);

        Task RemoveDayAsync(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct = default);

        Task<List<DayConfigDto>> GetConfigsAsync(
            int doctorId,
            CancellationToken ct = default);

        // ── Slot Generation ──
        Task<GenerateSlotsResponse> GenerateSlotsAsync(
            int doctorId,
            GenerateSlotsByConfigRequest request,
            CancellationToken ct = default);

        // ── Exceptions (Day Off / Custom Hours) ──
        Task AddDayOffAsync(
            int doctorId,
            CreateDayOffRequest request,
            CancellationToken ct = default);

        Task AddCustomHoursAsync(
            int doctorId,
            CreateCustomHoursRequest request,
            CancellationToken ct = default);

        Task RemoveExceptionAsync(
            int doctorId,
            DateTime date,
            CancellationToken ct = default);
    }
}
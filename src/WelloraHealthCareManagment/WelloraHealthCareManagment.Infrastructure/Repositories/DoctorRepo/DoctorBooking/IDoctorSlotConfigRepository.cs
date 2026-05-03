using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    public interface IDoctorSlotConfigRepository
    {
        Task<DoctorSlotConfig?> GetByDoctorAndDayAsync(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct = default);

        Task<List<DoctorSlotConfig>> GetActiveConfigsAsync(
            int doctorId,
            CancellationToken ct = default);

        Task<List<DoctorSlotConfig>> GetAllConfigsAsync(
            int doctorId,
            CancellationToken ct = default);

        /// للـ background job — يجيب كل الدكاترة اللي عندهم config
        Task<List<int>> GetDoctorsWithActiveConfigsAsync(
            CancellationToken ct = default);

        Task AddAsync(DoctorSlotConfig config, CancellationToken ct = default);
        Task UpdateAsync(DoctorSlotConfig config, CancellationToken ct = default);
        Task DeleteAsync(DoctorSlotConfig config, CancellationToken ct = default);
    }
}
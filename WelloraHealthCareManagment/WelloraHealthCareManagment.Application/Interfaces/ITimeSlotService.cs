using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface ITimeSlotService
    {
        /// توليد خانات لفترة معينة
        Task<GenerateSlotsResponse> GenerateSlotsAsync(
            int doctorId,
            GenerateSlotsRequest request,
            CancellationToken cancellationToken = default);

        /// جلب الخانات المتاحة لطبيب
        Task<List<AvailableSlotDto>> GetAvailableSlotsAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default);

        /// إضافة خانة يدوية
        Task<Guid> CreateManualSlotAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime,
            CancellationToken cancellationToken = default);

        /// حذف خانة (إذا لم تكن محجوزة)
        Task DeleteSlotAsync(
            Guid slotId,
            CancellationToken cancellationToken = default);

        /// حظر خانة (جعلها غير متاحة)
        Task BlockSlotAsync(
            Guid slotId,
            CancellationToken cancellationToken = default);
        // بترجع ال slots كلها ولاكن مجتمعه تحت اليوم الخاصه بيها 
        Task<GetDoctorTimeSlotsResponse> GetDoctorTimeSlotsInRangeAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            string? statusFilter = null,
            CancellationToken cancellationToken = default);
    }
}
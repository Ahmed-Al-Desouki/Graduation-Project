using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Schedules;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IDoctorScheduleService
    {

        /// إنشاء جدول جديد للطبيب
        Task<Guid> CreateScheduleAsync(
            int doctorId,
            CreateScheduleRequest request,
            CancellationToken cancellationToken = default);


        /// الحصول على الجدول النشط للطبيب
        Task<object?> GetActiveScheduleAsync(
            int doctorId,
            CancellationToken cancellationToken = default);

        /// إضافة إجازة (يوم مغلق)
        Task AddDayOffAsync(
            int doctorId,
            CreateDayOffRequest request,
            CancellationToken cancellationToken = default);

        /// إضافة ساعات عمل مخصصة ليوم معين
        Task AddCustomHoursAsync(
            int doctorId,
            CreateCustomHoursRequest request,
            CancellationToken cancellationToken = default);

        /// حذف استثناء
        Task RemoveExceptionAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default);
    }
}
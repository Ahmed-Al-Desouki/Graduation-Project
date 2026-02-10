using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Appointments;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IAppointmentService
    {
        /// حجز موعد
        Task<BookAppointmentResponse> BookAppointmentAsync(
            int patientId,
            BookAppointmentRequest request,
            CancellationToken cancellationToken = default);

        /// الحصول على تفاصيل موعد
        Task<AppointmentDetailsDto?> GetAppointmentDetailsAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        /// جلب مواعيد المريض
        Task<List<AppointmentDetailsDto>> GetPatientAppointmentsAsync(
            int patientId,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default);

        /// جلب مواعيد الطبيب
        Task<List<AppointmentDetailsDto>> GetDoctorAppointmentsAsync(
            int doctorId,
            DateTime? date = null,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default);

        /// إلغاء موعد
        Task CancelAppointmentAsync(
            Guid appointmentId,
            int userId,
            string userRole,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default);

        /// تأكيد موعد
        Task ConfirmAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        /// بدء موعد
        Task StartAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        /// إكمال موعد
        Task CompleteAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);
    }
}
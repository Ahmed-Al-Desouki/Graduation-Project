using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.DTOs.Payment;
using WelloraHealthCareManagment.Domain.ValueObjects;

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
            int requesterUserId,
            string requesterRole,
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

        Task<CancellationResult> CancelByPatientAsync(
            Guid appointmentId,
            int patientId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default);


        Task<CancellationResult> CancelAndBlockByDoctorAsync(
            Guid appointmentId,
            int doctorId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default);

        /// تأكيد موعد
        Task ConfirmAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default);

        /// بدء موعد
        Task StartAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default);

        /// إكمال موعد
        Task CompleteAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default);

        //دي لاختيار حجز للمريض للمتابعه فيه:حجز موجود فعليا
       Task<FollowUpResponse> BookFollowUpOnExistingSlotAsync(
           Guid originalAppointmentId,
           BookFollowUpExistingRequest request,
           int doctorId,
           CancellationToken ct = default);
        // دي لاختيار حجز للمريض للمتابعه فيه:حجز جديد انا هعمله للمريض
        Task<FollowUpResponse> CreateAndBookFollowUpSlotAsync(
            Guid originalAppointmentId,
            BookFollowUpNewRequest request,
            int doctorId,
            CancellationToken ct = default);
        // اعاده تشغيل access for medical history
        //Task GrantMedicalHistoryAccessAsync(
        //    int patientId,
        //    Guid appointmentId,
        //    CancellationToken ct = default);
        Task<InitiateBookingPaymentResponse> InitiateBookingWithPaymentAsync(
            int patientId,
            BookAppointmentRequest request,
            PaymentMethod paymentMethod,
            CancellationToken cancellationToken = default);
        Task ToggleMedicalHistoryAccessAsync(
            int patientId,
            Guid? appointmentId,
            ToggleMedicalAccessRequest request,
            CancellationToken ct = default);
        Task ExtendMedicalAccessExpiryAsync(
           int patientId,
           Guid appointmentId,
           ExtendAccessRequest request,
           CancellationToken ct = default);
    }
}

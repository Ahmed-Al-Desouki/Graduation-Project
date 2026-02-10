using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Domain.Factories
{
    /// Factory لإنشاء موعد مع كل الكيانات المرتبطة
    public interface IAppointmentFactory
    {
        /// إنشاء موعد كامل مع حجز الـ TimeSlot وإنشاء الإشعارات والصلاحيات
        AppointmentCreationResult CreateAppointment(
            TimeSlot timeSlot,
            int patientId,
            string? patientNotes = null,
            bool autoGrantMedicalHistoryAccess = true,
            bool sendNotifications = true);
    }

    /// نتيجة إنشاء الموعد - تحتوي على كل الكيانات المرتبطة
    public class AppointmentCreationResult
    {
        public Appointment Appointment { get; set; } = null!;
        public TimeSlot UpdatedTimeSlot { get; set; } = null!;
        public MedicalHistoryAccessGrant? AccessGrant { get; set; }
        //public List<AppointmentNotification> Notifications { get; set; } = new();
    }
}
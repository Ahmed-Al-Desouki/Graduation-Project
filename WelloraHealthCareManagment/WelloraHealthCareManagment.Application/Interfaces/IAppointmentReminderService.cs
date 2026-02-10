using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IAppointmentReminderService
    {
        /// Create all appointment reminders for both patient and doctor
        Task CreateAppointmentRemindersAsync(
            Appointment appointment,
            TimeSlot timeSlot,
            int patientId,
            int doctorId,
            CancellationToken cancellationToken = default);

        /// Cancel all reminders for an appointment
        Task CancelAppointmentRemindersAsync(
            Guid appointmentId,
            int patientId,
            CancellationToken cancellationToken = default);
    }
}
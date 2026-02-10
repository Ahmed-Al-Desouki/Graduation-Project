using Hangfire;
using HealthCare_.Models.V2;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    /// Creates appointment reminders using the existing ReminderV2 system
    public class AppointmentReminderService : IAppointmentReminderService
    {
        private readonly IReminderV2Service _reminderService;
        private readonly IReminderRepository _reminderRepository;
        private readonly ITimezoneHelper _timezoneHelper;
        private readonly ILogger<AppointmentReminderService> _logger;

        public AppointmentReminderService(
            IReminderV2Service reminderService,
            IReminderRepository reminderRepository,
            ITimezoneHelper timezoneHelper,
            ILogger<AppointmentReminderService> logger)
        {
            _reminderService = reminderService;
            _reminderRepository = reminderRepository;
            _timezoneHelper = timezoneHelper;
            _logger = logger;
        }

        public async Task CreateAppointmentRemindersAsync(
            Appointment appointment,
            TimeSlot timeSlot,
            int patientId,
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.StartTime);
                var timeZoneId = "Africa/Cairo";

                _logger.LogInformation(
                    "Creating appointment reminders: AppointmentId={AppointmentId}, DateTime={DateTime}, Patient={PatientId}, Doctor={DoctorId}",
                    appointment.Id, appointmentDateTime, patientId, doctorId);

                // Format TimeSpan correctly
                string formattedTime = FormatTimeSpan(timeSlot.StartTime);

                // ===== PATIENT REMINDERS =====

                // 1️. Patient: 24 hours before
                if (appointmentDateTime > DateTime.UtcNow.AddDays(1))
                {
                    await CreateReminderAsync(
                        patientId,
                        isDoctor: false,
                        appointment.Id,
                        "Appointment Tomorrow",
                        $"Reminder: Your appointment is tomorrow at {formattedTime}",
                        appointmentDateTime.AddDays(-1),
                        timeZoneId,
                        cancellationToken);
                }

                // 2️. Patient: 1 hour before
                if (appointmentDateTime > DateTime.UtcNow.AddHours(1))
                {
                    await CreateReminderAsync(
                        patientId,
                        isDoctor: false,
                        appointment.Id,
                        "Appointment in 1 Hour",
                        $"Your appointment starts in 1 hour at {formattedTime}",
                        appointmentDateTime.AddHours(-1),
                        timeZoneId,
                        cancellationToken);
                }

                // 3️. Patient: At appointment time
                await CreateReminderAsync(
                    patientId,
                    isDoctor: false,
                    appointment.Id,
                    "Appointment Now",
                    "Your appointment is starting now",
                    appointmentDateTime,
                    timeZoneId,
                    cancellationToken);

                // ===== DOCTOR REMINDERS =====

                // 4️. Doctor: 30 minutes before
                if (appointmentDateTime > DateTime.UtcNow.AddMinutes(30))
                {
                    await CreateReminderAsync(
                        doctorId,
                        isDoctor: true,
                        appointment.Id,
                        "Upcoming Appointment",
                        "You have an appointment in 30 minutes",
                        appointmentDateTime.AddMinutes(-30),
                        timeZoneId,
                        cancellationToken);
                }

                // 5️. Doctor: 5 minutes before
                if (appointmentDateTime > DateTime.UtcNow.AddMinutes(5))
                {
                    await CreateReminderAsync(
                        doctorId,
                        isDoctor: true,
                        appointment.Id,
                        "Appointment Starting Soon",
                        "Appointment starting in 5 minutes",
                        appointmentDateTime.AddMinutes(-5),
                        timeZoneId,
                        cancellationToken);
                }

                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForPatientAsync(patientId));

                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForDoctorAsync(doctorId));

                _logger.LogInformation(
                    "Successfully created appointment reminders for AppointmentId={AppointmentId}",
                    appointment.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error creating appointment reminders for AppointmentId={AppointmentId}",
                    appointment.Id);
            }
        }

        public async Task CancelAppointmentRemindersAsync(
            Guid appointmentId,
            int patientId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Cancelling reminders for AppointmentId={AppointmentId}",
                    appointmentId);

                // Get all reminders for this appointment
                var reminders = await _reminderRepository.GetAllByPatientIdAsync(patientId);

                var appointmentReminders = reminders
                    .Where(r => r.AppointmentId == appointmentId && r.IsActive)
                    .ToList();

                foreach (var reminder in appointmentReminders)
                {
                    reminder.IsActive = false;
                    reminder.Status = Enums.ReminderStatus.Dismissed;
                    reminder.UpdatedAt = DateTime.UtcNow;
                    await _reminderRepository.UpdateAsync(reminder);
                }

                _logger.LogInformation(
                    "Cancelled {Count} reminders for AppointmentId={AppointmentId}",
                    appointmentReminders.Count, appointmentId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error cancelling reminders for AppointmentId={AppointmentId}",
                    appointmentId);
            }
        }

        private async Task CreateReminderAsync(
            int userId,
            bool isDoctor, 
            Guid appointmentId,
            string title,
            string message,
            DateTime scheduledDateTime,
            string timeZoneId,
            CancellationToken cancellationToken)
        {
            if (scheduledDateTime <= DateTime.UtcNow)
            {
                _logger.LogWarning(
                    "Skipping reminder creation - scheduled time in the past: {ScheduledTime}",
                    scheduledDateTime);
                return;
            }

            var reminder = new ReminderV2
            {
                PatientId = (isDoctor ? null : (int?)userId),  
                DoctorId = isDoctor ? (int?)userId : null,
                Type = Enums.ReminderType.Appointment,
                Title = title,
                Message = message,
                StartDateUtc = scheduledDateTime,
                EndDateUtc = scheduledDateTime,
                TimeZoneId = timeZoneId,
                AppointmentId = appointmentId,
                IsActive = true,
                IsSimpleEveryXHours = false,
                FirstDoseTime = null,
                IntervalHours = null,
                RRULE = "FREQ=DAILY;COUNT=1",
                Status = Enums.ReminderStatus.Active,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _reminderRepository.AddAsync(reminder);

            _logger.LogInformation(
                "Created appointment reminder: {UserType}Id={UserId}, AppointmentId={AppointmentId}, Title={Title}",
                isDoctor ? "Doctor" : "Patient", userId, appointmentId, title);
        }

        // Helper
        private string FormatTimeSpan(TimeSpan time)
        {
            var totalHours = (int)time.TotalHours;
            var minutes = time.Minutes;

            if (totalHours == 0)
            {
                return $"12:{minutes:00} AM";
            }
            else if (totalHours < 12)
            {
                return $"{totalHours}:{minutes:00} AM";
            }
            else if (totalHours == 12)
            {
                return $"12:{minutes:00} PM";
            }
            else
            {
                return $"{totalHours - 12}:{minutes:00} PM";
            }
        }
    }
}
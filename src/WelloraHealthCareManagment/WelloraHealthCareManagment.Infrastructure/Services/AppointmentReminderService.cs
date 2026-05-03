using Hangfire;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    /// Creates appointment reminders using the existing ReminderV2 system
    public class AppointmentReminderService : IAppointmentReminderService
    {
        private readonly IReminderV2Service _reminderService;
        private readonly IReminderRepository _reminderRepository;
        private readonly IReminderOccurrencesCacheRepository _cacheRepository;
        private readonly ITimezoneHelper _timezoneHelper;
        private readonly ILogger<AppointmentReminderService> _logger;

        public AppointmentReminderService(
            IReminderV2Service reminderService,
            IReminderRepository reminderRepository,
            IReminderOccurrencesCacheRepository cacheRepository,
            ITimezoneHelper timezoneHelper,
            ILogger<AppointmentReminderService> logger)
        {
            _reminderService = reminderService;
            _reminderRepository = reminderRepository;
            _cacheRepository = cacheRepository;
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
                var appointmentUtc = _timezoneHelper.ConvertUserTimezoneToUtc(
                    appointmentDateTime,
                    timeZoneId);
                var nowUtc = DateTime.UtcNow;

                var existingReminders = await _reminderRepository.GetByAppointmentIdAsync(appointment.Id);
                if (existingReminders.Any())
                {
                    _logger.LogWarning(
                        "Found {Count} existing reminders for AppointmentId={AppointmentId}. Rebuilding them to avoid partial or duplicate state.",
                        existingReminders.Count,
                        appointment.Id);

                    foreach (var existingReminder in existingReminders)
                    {
                        await _cacheRepository.DeleteByReminderIdAsync(existingReminder.Id);
                        await _reminderRepository.HardDeleteAsync(existingReminder.Id);
                    }
                }

                _logger.LogInformation(
                    "Creating appointment reminders: AppointmentId={AppointmentId}, DateTimeLocal={DateTimeLocal}, DateTimeUtc={DateTimeUtc}",
                    appointment.Id, appointmentDateTime, appointmentUtc);

                string formattedTime = FormatTimeSpan(timeSlot.StartTime);

                // PATIENT REMINDERS

                if (appointmentUtc > nowUtc.AddHours(1))
                {
                    await CreateReminderAsync(patientId, false, appointment.Id,
                        "Appointment in 1 Hour",
                        $"Your appointment starts in 1 hour at {formattedTime}",
                        appointmentDateTime.AddHours(-1), timeZoneId, cancellationToken);
                }

                await CreateReminderAsync(patientId, false, appointment.Id,
                    "Appointment Now",
                    "Your appointment is starting now",
                    appointmentDateTime, timeZoneId, cancellationToken);

                // DOCTOR REMINDERS

                if (appointmentUtc > nowUtc.AddMinutes(5))
                {
                    await CreateReminderAsync(doctorId, true, appointment.Id,
                        "Appointment Starting Soon",
                        "Appointment starting in 5 minutes",
                        appointmentDateTime.AddMinutes(-5), timeZoneId, cancellationToken);
                }

                // ✅ FIX: Removed the bulk BackgroundJob.Enqueue calls here
                //    Each CreateReminderAsync now enqueues its own GenerateForReminderAsync

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

                var appointmentReminders = await _reminderRepository
                    .GetByAppointmentIdAsync(appointmentId);

                var activeReminders = appointmentReminders
                    .Where(r => r.IsActive)
                    .ToList();

                foreach (var reminder in activeReminders)
                {
                    await _cacheRepository.DeleteByReminderIdAsync(reminder.Id);
                    await _reminderRepository.HardDeleteAsync(reminder.Id);
                }

                _logger.LogInformation(
                    "Hard deleted {Count} reminders for AppointmentId={AppointmentId}",
                    activeReminders.Count, appointmentId);
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
            // ✅ Convert to UTC first for correct comparison
            var scheduledUtc = _timezoneHelper.ConvertUserTimezoneToUtc(scheduledDateTime, timeZoneId);

            _logger.LogInformation(
                "CreateReminderAsync: {UserType}={UserId}, Title={Title}, ScheduledLocal={Local}, ScheduledUtc={Utc}, NowUtc={Now}",
                isDoctor ? "Doctor" : "Patient", userId, title,
                scheduledDateTime, scheduledUtc, DateTime.UtcNow);

            if (scheduledUtc <= DateTime.UtcNow)
            {
                _logger.LogWarning(
                    "Skipping reminder '{Title}' — scheduled UTC {ScheduledUtc} is in the past (now={Now})",
                    title, scheduledUtc, DateTime.UtcNow);
                return;
            }

            // ✅ FIX: Use IReminderV2Service.CreateAsync with Once mode
            //    Same logic as manual reminders — no RRULE, no Simple
            //    GenerateForReminderAsync (MODE 0) handles the single occurrence correctly
            var dto = new CreateReminderV2Dto
            {
                Type = ReminderEnums.ReminderType.Appointment,
                Title = title,
                Message = message,
                StartDate = scheduledDateTime,   // local Cairo time
                EndDate = scheduledDateTime,
                TimeZoneId = timeZoneId,
                AppointmentId = appointmentId,
                RRULE = null,
                Simple = null,
                PrescriptionId = null,
                PrescriptionItemId = null
            };

            try
            {
                if (!isDoctor)
                {
                    // Patient reminder — goes through CreateAsync → GenerateForReminderAsync
                    var reminder = await _reminderService.CreateAsync(userId, dto);
                    _logger.LogInformation(
                        "✅ Patient reminder Id={Id} created: Title={Title}, ScheduledUtc={Utc}",
                        reminder.Id, title, scheduledUtc);
                }
                else
                {
                    // Doctor reminder — CreateAsync doesn't support doctorId directly
                    // Create manually but reuse the Once mode pattern
                    var reminder = new ReminderV2
                    {
                        PatientId = null,
                        DoctorId = userId,
                        Type = ReminderEnums.ReminderType.Appointment,
                        Title = title,
                        Message = message,
                        StartDateUtc = scheduledUtc,
                        EndDateUtc = scheduledUtc,
                        TimeZoneId = timeZoneId,
                        AppointmentId = appointmentId,
                        IsActive = true,
                        IsSimpleEveryXHours = false,
                        RRULE = null,
                        FirstDoseTime = null,
                        IntervalHours = null,
                        Status = ReminderEnums.ReminderStatus.Active,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    await _reminderRepository.AddAsync(reminder);

                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                        j => j.GenerateForDoctorAsync(userId));

                    _logger.LogInformation(
                        "✅ Doctor reminder Id={Id} created: Title={Title}, ScheduledUtc={Utc}",
                        reminder.Id, title, scheduledUtc);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "❌ Failed to create reminder '{Title}' for {UserType}={UserId}",
                    title, isDoctor ? "Doctor" : "Patient", userId);
                throw;
            }
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

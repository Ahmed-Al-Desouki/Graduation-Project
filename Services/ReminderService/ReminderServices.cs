using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.Context;
using HealthCare_.Models.DTOs.ReminderDTO;
using HealthCare_.Models.EnumForModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.ReminderModels;
using HealthCare_.Models.SharedModels;
using Microsoft.EntityFrameworkCore;
using static HealthCare_.Models.EnumForModels.Enums;

namespace HealthCare_.Services.Reminder
{
    public class ReminderService : IReminderService
    {
        private readonly HealthCarePlusContext _context;

        public ReminderService(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<HealthCare_.Models.PatientModels.Reminder> CreateManualReminderAsync(int patientId, CreateReminderDto dto)
        {
            var patient = await _context.Patients.FindAsync(patientId);
            if (patient == null) throw new Exception("Patient not found");

            var reminder = new HealthCare_.Models.PatientModels.Reminder
            {
                PatientID = patientId,
                Type = dto.Type ?? ReminderType.Custom,
                Name = dto.Name,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Frequency = dto.Frequency,
                IntervalHours = dto.IntervalHours,
                BaseTime = dto.BaseTime,
                Message = dto.Message ?? "تذكير مخصص",
                Status = ReminderStatus.Pending,
                IsActive = true,
                IsLocalNotification = true
            };

            _context.Reminders.Add(reminder);
            await _context.SaveChangesAsync();

            await GenerateInstancesAsync(reminder);

            return reminder;
        }

        public async Task<HealthCare_.Models.PatientModels.Reminder> CreateFromPrescriptionMedAsync(int prescriptionMedId)
        {
            var med = await _context.PrescriptionMeds
                .Include(pm => pm.DosingSchedules)
                .Include(pm => pm.Prescription)
                .FirstOrDefaultAsync(pm => pm.ID == prescriptionMedId);

            if (med == null) throw new Exception("PrescriptionMed not found");

            var reminder = new HealthCare_.Models.PatientModels.Reminder
            {
                PatientID = med.Prescription.PatientID,
                Type = ReminderType.Medication,
                Name = med.MedicationName,
                StartDate = med.StartDate ?? med.Prescription.PrescriptionDate,
                EndDate = med.EndDate ?? med.Prescription.EndDate,
                Frequency = RepeatFrequency.Daily,
                BaseTime = TimeSpan.Zero,
                Message = med.Instructions ?? $"خد {med.Dosage} من {med.MedicationName}",
                PrescriptionMedID = med.ID,
                Status = ReminderStatus.Pending,
                IsActive = true,
                IsLocalNotification = true
            };

            _context.Reminders.Add(reminder);
            await _context.SaveChangesAsync();

            await GenerateInstancesFromDosingSchedulesAsync(reminder, med.DosingSchedules);

            return reminder;
        }

        private async Task GenerateInstancesAsync(HealthCare_.Models.PatientModels.Reminder reminder)
        {
            var current = reminder.StartDate.Date + reminder.BaseTime;
            var end = reminder.EndDate?.Date ?? current.AddYears(1);

            while (current.Date <= end.Date)
            {
                if (current >= DateTime.UtcNow.AddMinutes(-5))
                {
                    _context.ReminderInstances.Add(new HealthCare_.Models.PatientModels.ReminderInstance
                    {
                        ReminderID = reminder.ReminderID,
                        DueDateTime = current,
                        Status = ReminderStatus.Pending
                    });
                }

                current = reminder.Frequency switch
                {
                    RepeatFrequency.Once => end.AddDays(1),
                    RepeatFrequency.Daily => current.AddDays(1),
                    RepeatFrequency.Weekly => current.AddDays(7),
                    RepeatFrequency.EveryXHours => current.AddHours(reminder.IntervalHours ?? 24),
                    RepeatFrequency.Custom => current.AddDays(1),
                    _ => current.AddDays(1)
                };
            }

            await _context.SaveChangesAsync();
        }

        private async Task GenerateInstancesFromDosingSchedulesAsync(HealthCare_.Models.PatientModels.Reminder reminder, ICollection<DosingSchedule> schedules)
        {
            if (!schedules.Any()) return;

            var start = reminder.StartDate.Date;
            var end = reminder.EndDate?.Date ?? start.AddYears(1);

            for (var day = start; day.Date <= end.Date; day = day.AddDays(1))
            {
                foreach (var schedule in schedules)
                {
                    var due = day + schedule.DailyTime;
                    if (due >= DateTime.UtcNow.AddMinutes(-5))
                    {
                        _context.ReminderInstances.Add(new HealthCare_.Models.PatientModels.ReminderInstance
                        {
                            ReminderID = reminder.ReminderID,
                            DueDateTime = due,
                            Status = ReminderStatus.Pending
                        });
                    }
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task ConfirmIntakeAsync(int instanceId, IntakeStatus status = IntakeStatus.Taken)
        {
            var instance = await _context.ReminderInstances
                .Include(i => i.Reminder)
                .FirstOrDefaultAsync(i => i.InstanceID == instanceId);

            if (instance == null || (instance.Status != ReminderStatus.Pending && instance.Status != ReminderStatus.Active))
                throw new Exception("Instance not found or already confirmed");

            instance.Status = ReminderStatus.Completed;
            instance.ConfirmedAt = DateTime.UtcNow;

            if (instance.Reminder.Type == ReminderType.Medication && instance.Reminder.PrescriptionMedID.HasValue)
            {
                var intake = new MedicationsIntake
                {
                    PrescriptionMedID = instance.Reminder.PrescriptionMedID.Value,
                    DateTaken = instance.DueDateTime,
                    Status = status,
                    ReminderInstanceID = instance.InstanceID
                };

                _context.MedicationsIntakes.Add(intake);
                instance.IntakeID = intake.IntakeID;
            }

            await _context.SaveChangesAsync();
        }

        public async Task MarkOverdueAsync()
        {
            var gracePeriod = TimeSpan.FromMinutes(30);
            var now = DateTime.UtcNow;

            var overdueInstances = await _context.ReminderInstances
                .Where(i => i.Reminder.IsActive &&
                            (i.Status == ReminderStatus.Pending || i.Status == ReminderStatus.Active) &&
                            i.DueDateTime < now - gracePeriod)
                .ToListAsync();

            foreach (var i in overdueInstances)
            {
                i.Status = ReminderStatus.Overdue;
            }

            await _context.SaveChangesAsync();
        }

        public async Task ExpireRemindersAsync()
        {
            var now = DateTime.UtcNow.Date;

            var expiredReminders = await _context.Reminders
                .Where(r => r.IsActive && r.EndDate.HasValue && r.EndDate.Value.Date < now)
                .Include(r => r.Instances)
                .ToListAsync();

            foreach (var reminder in expiredReminders)
            {
                reminder.IsActive = false;
                reminder.Status = ReminderStatus.Expired;
                reminder.UpdatedAt = DateTime.UtcNow;

                var futureInstances = reminder.Instances
                    .Where(i => i.DueDateTime.Date >= now &&
                                (i.Status == ReminderStatus.Pending ||
                                 i.Status == ReminderStatus.Active ||
                                 i.Status == ReminderStatus.Overdue))
                    .ToList();

                foreach (var instance in futureInstances)
                {
                    instance.Status = ReminderStatus.Expired;
                }

                // _context.ReminderInstances.RemoveRange(futureInstances); // اختياري حذف
            }

            await _context.SaveChangesAsync();
        }

        public async Task DeleteReminderAsync(int reminderId)
        {
            var reminder = await _context.Reminders
                .Include(r => r.Instances)
                .FirstOrDefaultAsync(r => r.ReminderID == reminderId);

            if (reminder == null) throw new Exception("Reminder not found");

            _context.ReminderInstances.RemoveRange(reminder.Instances);
            _context.Reminders.Remove(reminder);

            await _context.SaveChangesAsync();
        }

        public async Task UpdateReminderAsync(int reminderId, UpdateReminderDto dto)
        {
            var reminder = await _context.Reminders
                .Include(r => r.Instances)
                .FirstOrDefaultAsync(r => r.ReminderID == reminderId);

            if (reminder == null) throw new Exception("Reminder not found");

            reminder.Name = dto.Name;
            reminder.StartDate = dto.StartDate;
            reminder.EndDate = dto.EndDate;
            reminder.Frequency = dto.Frequency;
            reminder.IntervalHours = dto.IntervalHours;
            reminder.BaseTime = dto.BaseTime;
            reminder.Message = dto.Message;

            _context.ReminderInstances.RemoveRange(reminder.Instances);
            await _context.SaveChangesAsync();

            await GenerateInstancesAsync(reminder);
        }
    }
}
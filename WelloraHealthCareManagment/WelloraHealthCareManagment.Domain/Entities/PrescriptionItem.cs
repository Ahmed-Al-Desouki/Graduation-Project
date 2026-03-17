using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class PrescriptionItem : BaseEntity
    {
        public Guid PrescriptionId { get; private set; }
        public Prescription Prescription { get; private set; }
        public string MedicationName { get; private set; } = string.Empty;
        public string? MedicationCode { get; private set; }
        public string Dosage { get; private set; } = string.Empty;
        public string Frequency { get; private set; } = string.Empty;
        public string Duration { get; private set; } = string.Empty;
        public int Quantity { get; private set; }
        public string? Instructions { get; private set; }


        public RepeatFrequency? ReminderFrequencyType { get; private set; }
        public List<DayOfWeek>? ReminderWeeklyDays { get; private set; }
        public List<TimeSpan>? ReminderDailyDoseTimes { get; private set; }
        public int? ReminderIntervalHours { get; private set; }
        public DateTime? ReminderStartDate { get; private set; }
        public DateTime? ReminderEndDate { get; private set; }
        public TimeSpan? ReminderFirstDoseTime { get; private set; }



        private PrescriptionItem() { }

        public static PrescriptionItem Create(
            Guid prescriptionId,
            string medicationName,
            string dosage,
            string frequency,
            string duration,
            int quantity,
            string? instructions = null,
            RepeatFrequency? reminderFrequencyType = null,
            List<DayOfWeek>? weeklyDays = null,
            List<TimeSpan>? dailyDoseTimes = null,
            int? intervalHours = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            TimeSpan? firstDoseTime = null)
        {
            if (prescriptionId == Guid.Empty)
                throw new DomainException("Prescription ID cannot be empty");
            if (string.IsNullOrWhiteSpace(medicationName))
                throw new DomainException("Medication name is required");
            if (string.IsNullOrWhiteSpace(dosage))
                throw new DomainException("Dosage is required");
            if (string.IsNullOrWhiteSpace(frequency))
                throw new DomainException("Frequency is required");
            if (string.IsNullOrWhiteSpace(duration))
                throw new DomainException("Duration is required");
            if (quantity <= 0)
                throw new DomainException("Quantity must be positive");

            var item = new PrescriptionItem
            {
                Id = Guid.NewGuid(),
                PrescriptionId = prescriptionId,
                MedicationName = medicationName,
                Dosage = dosage,
                Frequency = frequency,
                Duration = duration,
                Quantity = quantity,
                Instructions = instructions,
                CreatedAt = DateTime.UtcNow,
                //UpdatedAt = DateTime.UtcNow
            };

            if (reminderFrequencyType.HasValue)
            {
                item.SetReminder(
                    reminderFrequencyType.Value,
                    weeklyDays,
                    dailyDoseTimes,
                    intervalHours,
                    startDate,
                    endDate,
                    firstDoseTime);
            }

            return item;
        }

        public void SetReminder(
            RepeatFrequency frequencyType,
            List<DayOfWeek>? weeklyDays = null,
            List<TimeSpan>? dailyDoseTimes = null,
            int? intervalHours = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            TimeSpan? firstDoseTime = null)
        {
            ReminderFrequencyType = frequencyType;
            ReminderWeeklyDays = weeklyDays;
            ReminderDailyDoseTimes = dailyDoseTimes;
            ReminderIntervalHours = intervalHours;
            ReminderStartDate = startDate;
            ReminderEndDate = endDate;
            ReminderFirstDoseTime = firstDoseTime;
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
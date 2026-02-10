using WelloraHealthCareManagement.Domain.Exceptions;
using HealthCare_.Models.DoctorModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class DoctorScheduleTemplate : BaseEntity
    {
        public int DoctorId { get; private set; } 
        public string TemplateName { get; private set; } = string.Empty;
        public bool IsActive { get; private set; }
        public int SlotDurationMinutes { get; private set; }
        public int BufferTimeMinutes { get; private set; }
        public DateTime EffectiveFromDate { get; private set; }
        public DateTime? EffectiveToDate { get; private set; }

        public Doctor Doctor { get; private set; } = null!;

        private readonly List<ScheduleTimeRange> _timeRanges = new();
        public IReadOnlyCollection<ScheduleTimeRange> TimeRanges => _timeRanges.AsReadOnly();

        public ICollection<TimeSlot> GeneratedSlots { get; private set; } = new List<TimeSlot>();

        private DoctorScheduleTemplate() { }

        public static DoctorScheduleTemplate Create(
            int doctorId,
            string templateName,
            int slotDurationMinutes,
            int bufferTimeMinutes,
            DateTime effectiveFromDate,
            DateTime? effectiveToDate = null)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            if (string.IsNullOrWhiteSpace(templateName))
                throw new DomainException("Template name is required");

            if (slotDurationMinutes is not (15 or 20 or 30 or 45 or 60))
                throw new DomainException("Slot duration must be 15, 20, 30, 45, or 60 minutes");

            if (bufferTimeMinutes < 0 || bufferTimeMinutes > 60)
                throw new DomainException("Buffer time must be between 0 and 60 minutes");

            if (effectiveToDate.HasValue && effectiveToDate < effectiveFromDate)
                throw new DomainException("End date must be after start date");

            return new DoctorScheduleTemplate
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                TemplateName = templateName.Trim(),
                SlotDurationMinutes = slotDurationMinutes,
                BufferTimeMinutes = bufferTimeMinutes,
                EffectiveFromDate = effectiveFromDate.Date,
                EffectiveToDate = effectiveToDate?.Date,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void AddTimeRange(DayOfWeek day, TimeSpan startTime, TimeSpan endTime)
        {
            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");

            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");

            var range = ScheduleTimeRange.Create(Id, day, startTime, endTime);
            _timeRanges.Add(range);
            UpdatedAt = DateTime.UtcNow;
        }

        public void Activate()
        {
            IsActive = true;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Deactivate()
        {
            IsActive = false;
            UpdatedAt = DateTime.UtcNow;
        }

        public void UpdateEffectiveDates(DateTime fromDate, DateTime? toDate)
        {
            if (toDate.HasValue && toDate < fromDate)
                throw new DomainException("End date must be after start date");

            EffectiveFromDate = fromDate.Date;
            EffectiveToDate = toDate?.Date;
            UpdatedAt = DateTime.UtcNow;
        }

        public void UpdateSlotSettings(int slotDurationMinutes, int bufferTimeMinutes)
        {
            if (slotDurationMinutes is not (15 or 20 or 30 or 45 or 60))
                throw new DomainException("Invalid slot duration");

            if (bufferTimeMinutes < 0 || bufferTimeMinutes > 60)
                throw new DomainException("Invalid buffer time");

            SlotDurationMinutes = slotDurationMinutes;
            BufferTimeMinutes = bufferTimeMinutes;
            UpdatedAt = DateTime.UtcNow;
        }

        public bool IsEffectiveOn(DateTime date)
        {
            var checkDate = date.Date;
            return IsActive
                && checkDate >= EffectiveFromDate
                && (EffectiveToDate == null || checkDate <= EffectiveToDate);
        }
    }
}
using WelloraHealthCareManagement.Domain.Exceptions;
using HealthCare_.Models.DoctorModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class DoctorScheduleTemplate : BaseEntity
    {
        public int DoctorId { get; private set; }
        public string TemplateName { get; private set; } = string.Empty;
        public bool IsActive { get; private set; }
        public bool IsOpenEnded { get; private set; }
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
            if (slotDurationMinutes < 5 || slotDurationMinutes > 480)
                throw new DomainException("Slot duration must be between 5 and 480 minutes");
            if (bufferTimeMinutes < 0 || bufferTimeMinutes > 60)
                throw new DomainException("Buffer time must be between 0 and 60 minutes");
            if (effectiveFromDate.Date < DateTime.UtcNow.Date)
                throw new DomainException("Effective from date cannot be in the past");
            if (effectiveToDate.HasValue && effectiveToDate.Value <= effectiveFromDate)
                throw new DomainException("Effective to date must be after from date");

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
                IsOpenEnded = !effectiveToDate.HasValue,
                CreatedAt = DateTime.UtcNow
                //NO UpdatedAt - let DB handle it
            };
        }

        public void UpdateSlotDuration(int durationMinutes)
        {
            if (durationMinutes < 5 || durationMinutes > 480)
                throw new DomainException("Slot duration must be between 5 and 480 minutes");

            SlotDurationMinutes = durationMinutes;
        }

        public void UpdateBufferTime(int bufferMinutes)
        {
            if (bufferMinutes < 0 || bufferMinutes > 60)
                throw new DomainException("Buffer time must be between 0 and 60 minutes");

            BufferTimeMinutes = bufferMinutes;
        }

        public void MakeOpenEnded()
        {
            EffectiveToDate = null;
            IsOpenEnded = true;
        }

        public void SetEndDate(DateTime endDate)
        {
            if (endDate <= EffectiveFromDate)
                throw new DomainException("End date must be after start date");

            EffectiveToDate = endDate.Date;
            IsOpenEnded = false;
        }

        public void RemoveTimeRange(DayOfWeek dayOfWeek)
        {
            var range = _timeRanges.FirstOrDefault(tr => tr.DayOfWeek == dayOfWeek);

            if (range == null)
                throw new DomainException($"No time range found for {dayOfWeek}");

            range.MarkUnavailable();
        }

        public void DeleteTimeRange(DayOfWeek dayOfWeek)
        {
            var range = _timeRanges.FirstOrDefault(tr => tr.DayOfWeek == dayOfWeek);

            if (range == null)
                throw new DomainException($"No time range found for {dayOfWeek}");

            _timeRanges.Remove(range);
        }

        public void AddTimeRange(DayOfWeek day, TimeSpan startTime, TimeSpan endTime)
        {
            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");

            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");

            var range = ScheduleTimeRange.Create(Id, day, startTime, endTime);
            _timeRanges.Add(range);
        }

        public void Activate()
        {
            IsActive = true;
        }

        public void Deactivate()
        {
            IsActive = false;
        }

        public void UpdateEffectiveDates(DateTime fromDate, DateTime? toDate)
        {
            if (toDate.HasValue && toDate < fromDate)
                throw new DomainException("End date must be after start date");

            EffectiveFromDate = fromDate.Date;
            EffectiveToDate = toDate?.Date;
        }

        public void UpdateSlotSettings(int slotDurationMinutes, int bufferTimeMinutes)
        {
            if (slotDurationMinutes is not (15 or 20 or 30 or 45 or 60))
                throw new DomainException("Invalid slot duration");

            if (bufferTimeMinutes < 0 || bufferTimeMinutes > 60)
                throw new DomainException("Invalid buffer time");

            SlotDurationMinutes = slotDurationMinutes;
            BufferTimeMinutes = bufferTimeMinutes;
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
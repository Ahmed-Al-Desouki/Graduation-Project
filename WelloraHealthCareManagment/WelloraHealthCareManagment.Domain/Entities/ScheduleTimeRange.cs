using WelloraHealthCareManagement.Domain.Exceptions;

namespace WelloraHealthCareManagement.Domain.Entities
{
     
    /// فترة زمنية في يوم معين
    /// مثال: الاثنين من 10:00 إلى 14:00
     
    public class ScheduleTimeRange : BaseEntity
    {
 
        public Guid ScheduleTemplateId { get; private set; }

        public DayOfWeek DayOfWeek { get; private set; }

        public TimeSpan StartTime { get; private set; }
 
        public TimeSpan EndTime { get; private set; }

        public bool IsAvailable { get; private set; }

        // === Navigation ===
        public DoctorScheduleTemplate ScheduleTemplate { get; private set; } = null!;

        private ScheduleTimeRange() { }

 
        /// إنشاء فترة زمنية جديدة
 
        public static ScheduleTimeRange Create(
            Guid scheduleTemplateId,
            DayOfWeek dayOfWeek,
            TimeSpan startTime,
            TimeSpan endTime)
        {
            if (scheduleTemplateId == Guid.Empty)
                throw new DomainException("Schedule template ID cannot be empty");

            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");

            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");

            return new ScheduleTimeRange
            {
                Id = Guid.NewGuid(),
                ScheduleTemplateId = scheduleTemplateId,
                DayOfWeek = dayOfWeek,
                StartTime = startTime,
                EndTime = endTime,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

         
        /// تعطيل/تفعيل هذه الفترة
         
        public void SetAvailability(bool isAvailable)
        {
            IsAvailable = isAvailable;
            UpdatedAt = DateTime.UtcNow;
        }

         
        /// تحديث الأوقات
         public void UpdateTimes(TimeSpan startTime, TimeSpan endTime)
         {
         if (endTime <= startTime)
            throw new DomainException("End time must be after start time");

            StartTime = startTime;
            EndTime = endTime;
            UpdatedAt = DateTime.UtcNow;
         }
    }
}
//using WelloraHealthCareManagement.Domain.Exceptions;

//namespace WelloraHealthCareManagement.Domain.Entities
//{
//    public class ScheduleTimeRange : BaseEntity
//    {
//        public Guid ScheduleTemplateId { get; private set; }
//        public DayOfWeek DayOfWeek { get; private set; }
//        public TimeSpan StartTime { get; private set; }
//        public TimeSpan EndTime { get; private set; }
//        public bool IsAvailable { get; private set; }

//        public DoctorScheduleTemplate ScheduleTemplate { get; private set; } = null!;

//        private ScheduleTimeRange() { }

//        public static ScheduleTimeRange Create(
//            Guid scheduleTemplateId,
//            DayOfWeek dayOfWeek,
//            TimeSpan startTime,
//            TimeSpan endTime)
//        {
//            if (scheduleTemplateId == Guid.Empty)
//                throw new DomainException("Schedule template ID cannot be empty");
//            if (endTime <= startTime)
//                throw new DomainException("End time must be after start time");
//            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
//                throw new DomainException("Invalid time range");

//            return new ScheduleTimeRange
//            {
//                Id = Guid.NewGuid(),
//                ScheduleTemplateId = scheduleTemplateId,
//                DayOfWeek = dayOfWeek,
//                StartTime = startTime,
//                EndTime = endTime,
//                IsAvailable = true,
//                CreatedAt = DateTime.UtcNow
//            };
//        }

//        public void MarkUnavailable()
//        {
//            IsAvailable = false;
//        }

//        public void MarkAvailable()
//        {
//            IsAvailable = true;
//        }
//        public void SetAvailability(bool isAvailable)
//        {
//            IsAvailable = isAvailable;
//        }

//        public void UpdateTime(TimeSpan newStartTime, TimeSpan newEndTime)
//        {
//            if (newStartTime >= newEndTime)
//                throw new DomainException("Start time must be before end time");

//            StartTime = newStartTime;
//            EndTime = newEndTime;
//        }
//    }
//}
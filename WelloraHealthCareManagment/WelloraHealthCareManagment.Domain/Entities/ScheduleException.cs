using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using HealthCare_.Models.DoctorModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class ScheduleException : BaseEntity
    {
        public int DoctorId { get; private set; }
        public DateTime ExceptionDate { get; private set; }
        public ExceptionType ExceptionType { get; private set; }
        public string? Reason { get; private set; }
        public TimeSpan? CustomStartTime { get; private set; }
        public TimeSpan? CustomEndTime { get; private set; }

        public Doctor Doctor { get; private set; } = null!;

        private ScheduleException() { }

        public static ScheduleException CreateDayOff(
            int doctorId,
            DateTime date,
            string? reason = null)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            return new ScheduleException
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                ExceptionDate = date.Date,
                ExceptionType = ExceptionType.DayOff,
                Reason = reason?.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public static ScheduleException CreateCustomHours(
            int doctorId,
            DateTime date,
            TimeSpan startTime,
            TimeSpan endTime,
            string? reason = null)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");

            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");

            return new ScheduleException
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                ExceptionDate = date.Date,
                ExceptionType = ExceptionType.CustomHours,
                CustomStartTime = startTime,
                CustomEndTime = endTime,
                Reason = reason?.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public static ScheduleException CreateEmergency(
            int doctorId,
            DateTime date,
            string reason)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            if (string.IsNullOrWhiteSpace(reason))
                throw new DomainException("Emergency reason is required");

            return new ScheduleException
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                ExceptionDate = date.Date,
                ExceptionType = ExceptionType.Emergency,
                Reason = reason.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }
    }
}
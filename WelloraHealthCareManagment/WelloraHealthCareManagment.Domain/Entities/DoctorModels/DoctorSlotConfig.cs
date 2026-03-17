using HealthCare_.Models.DoctorModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;

namespace WelloraHealthCareManagment.Domain.Entities.DoctorModels
{
    public class DoctorSlotConfig : BaseEntity
    {
        public int DoctorId { get; private set; }
        public DayOfWeek DayOfWeek { get; private set; }
        public TimeSpan StartTime { get; private set; }
        public TimeSpan EndTime { get; private set; }
        public int SlotDurationMinutes { get; private set; }
        public int BufferTimeMinutes { get; private set; }
        public bool IsActive { get; private set; }

        public Doctor Doctor { get; private set; } = null!;

        private DoctorSlotConfig() { }

        public static DoctorSlotConfig Create(
            int doctorId,
            DayOfWeek dayOfWeek,
            TimeSpan startTime,
            TimeSpan endTime,
            int slotDurationMinutes,
            int bufferTimeMinutes)
        {
            Validate(doctorId, startTime, endTime, slotDurationMinutes, bufferTimeMinutes);

            return new DoctorSlotConfig
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                DayOfWeek = dayOfWeek,
                StartTime = startTime,
                EndTime = endTime,
                SlotDurationMinutes = slotDurationMinutes,
                BufferTimeMinutes = bufferTimeMinutes,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
        }

        public void Update(
            TimeSpan startTime,
            TimeSpan endTime,
            int slotDurationMinutes,
            int bufferTimeMinutes)
        {
            Validate(DoctorId, startTime, endTime, slotDurationMinutes, bufferTimeMinutes);
            StartTime = startTime;
            EndTime = endTime;
            SlotDurationMinutes = slotDurationMinutes;
            BufferTimeMinutes = bufferTimeMinutes;
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

        /// بتولّد الأوقات مع مراعاة أي Exception موجود لليوم ده
        public List<(TimeSpan Start, TimeSpan End)> GetEffectiveSlotTimes(
            ScheduleException? exception)
        {
            // DayOff → مفيش slots خالص
            if (exception?.ExceptionType == ExceptionType.DayOff)
                return new List<(TimeSpan, TimeSpan)>();

            // CustomHours → ولّد جوا الـ interval الجديد بس
            if (exception?.ExceptionType == ExceptionType.CustomHours
                && exception.CustomStartTime.HasValue
                && exception.CustomEndTime.HasValue)
            {
                return GenerateSlotTimesInRange(
                    exception.CustomStartTime.Value,
                    exception.CustomEndTime.Value);
            }

            // عادي → الـ Config الكامل
            return GenerateSlotTimesInRange(StartTime, EndTime);
        }

        public int EstimatedSlotsPerDay()
            => GetEffectiveSlotTimes(null).Count;

        private List<(TimeSpan Start, TimeSpan End)> GenerateSlotTimesInRange(
            TimeSpan from,
            TimeSpan to)
        {
            var result = new List<(TimeSpan, TimeSpan)>();
            var current = from;

            while (true)
            {
                var slotEnd = current.Add(TimeSpan.FromMinutes(SlotDurationMinutes));
                if (slotEnd > to) break;
                result.Add((current, slotEnd));
                current = slotEnd.Add(TimeSpan.FromMinutes(BufferTimeMinutes));
            }

            return result;
        }

        private static void Validate(
            int doctorId,
            TimeSpan startTime,
            TimeSpan endTime,
            int slotDurationMinutes,
            int bufferTimeMinutes)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");
            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");
            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");
            if (slotDurationMinutes < 5 || slotDurationMinutes > 480)
                throw new DomainException("Slot duration must be between 5 and 480 minutes");
            if (bufferTimeMinutes < 0 || bufferTimeMinutes > 60)
                throw new DomainException("Buffer time must be between 0 and 60 minutes");
            if ((endTime - startTime).TotalMinutes < slotDurationMinutes)
                throw new DomainException(
                    "Time range is too short for even one slot with the given duration");
        }
    }
}

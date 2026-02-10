using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using HealthCare_.Models.DoctorModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class TimeSlot : BaseEntity
    {
        public int DoctorId { get; private set; } // ✅ int
        public DateTime SlotDate { get; private set; }
        public TimeSpan StartTime { get; private set; }
        public TimeSpan EndTime { get; private set; }
        public SlotStatus Status { get; private set; }
        public Guid? GeneratedFromTemplateId { get; private set; }
        public bool IsManuallyCreated { get; private set; }

        public Doctor Doctor { get; private set; } = null!;
        public DoctorScheduleTemplate? GeneratedFromTemplate { get; private set; }
        public Appointment? Appointment { get; private set; }

        private TimeSlot() { }

        public static TimeSlot CreateFromTemplate(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime,
            Guid templateId)
        {
            ValidateSlotData(doctorId, slotDate, startTime, endTime);

            return new TimeSlot
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                SlotDate = slotDate.Date,
                StartTime = startTime,
                EndTime = endTime,
                Status = SlotStatus.Available,
                GeneratedFromTemplateId = templateId,
                IsManuallyCreated = false,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public static TimeSlot CreateManual(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime)
        {
            ValidateSlotData(doctorId, slotDate, startTime, endTime);

            return new TimeSlot
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                SlotDate = slotDate.Date,
                StartTime = startTime,
                EndTime = endTime,
                Status = SlotStatus.Available,
                IsManuallyCreated = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void Book()
        {
            if (Status != SlotStatus.Available)
                throw new DomainException($"Cannot book slot with status: {Status}");

            Status = SlotStatus.Booked;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Block()
        {
            if (Status == SlotStatus.Booked)
                throw new DomainException("Cannot block a booked slot");

            Status = SlotStatus.Blocked;
            UpdatedAt = DateTime.UtcNow;
        }

        public void MakeAvailable()
        {
            if (Status == SlotStatus.Completed)
                throw new DomainException("Cannot reopen completed slot");

            Status = SlotStatus.Available;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Complete()
        {
            if (Status != SlotStatus.Booked)
                throw new DomainException("Only booked slots can be completed");

            Status = SlotStatus.Completed;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Cancel()
        {
            if (Status == SlotStatus.Completed)
                throw new DomainException("Cannot cancel completed slot");

            Status = SlotStatus.Cancelled;
            UpdatedAt = DateTime.UtcNow;
        }

        private static void ValidateSlotData(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime)
        {
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            if (slotDate.Date < DateTime.UtcNow.Date)
                throw new DomainException("Cannot create slot in the past");

            if (endTime <= startTime)
                throw new DomainException("End time must be after start time");

            if (startTime < TimeSpan.Zero || endTime > TimeSpan.FromHours(24))
                throw new DomainException("Invalid time range");

            if ((endTime - startTime).TotalMinutes < 5)
                throw new DomainException("Slot duration must be at least 5 minutes");
        }
    }
}
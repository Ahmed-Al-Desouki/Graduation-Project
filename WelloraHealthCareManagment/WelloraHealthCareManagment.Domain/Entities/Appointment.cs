using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.V2;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class Appointment : BaseEntity
    {
        public Guid TimeSlotId { get; private set; }
        public int DoctorId { get; private set; } // ✅ int
        public int PatientId { get; private set; }
        public AppointmentStatus Status { get; private set; }
        public string? PatientNotes { get; private set; }

        public string? CancellationReason { get; private set; }
        public CancelledBy? CancelledBy { get; private set; }
        public DateTime? CancelledAt { get; private set; }

        public DateTime BookedAt { get; private set; }
        public DateTime? ConfirmedAt { get; private set; }
        public DateTime? StartedAt { get; private set; }
        public DateTime? CompletedAt { get; private set; }

        public TimeSlot TimeSlot { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;
        public Patient Patient { get; private set; } = null!;
        public AppointmentMedicalRecord? MedicalRecord { get; private set; }

        private readonly List<Prescription> _prescriptions = new();
        public IReadOnlyCollection<Prescription> Prescriptions => _prescriptions.AsReadOnly();

        private readonly List<MedicalHistoryAccessGrant> _accessGrants = new();
        public IReadOnlyCollection<MedicalHistoryAccessGrant> AccessGrants => _accessGrants.AsReadOnly();

        //private readonly List<Reminder> _reminders = new();
        //public IReadOnlyCollection<Reminder> Reminders => _reminders.AsReadOnly();

        private Appointment() { }

        public static Appointment Create(
            Guid timeSlotId,
            int doctorId,
            int patientId,
            string? patientNotes = null)
        {
            if (timeSlotId == Guid.Empty)
                throw new DomainException("TimeSlot ID cannot be empty");
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");
            if (patientId <= 0)
                throw new DomainException("Patient ID cannot be empty");

            return new Appointment
            {
                Id = Guid.NewGuid(),
                TimeSlotId = timeSlotId,
                DoctorId = doctorId,
                PatientId = patientId,
                Status = AppointmentStatus.Pending,
                PatientNotes = patientNotes?.Trim(),
                BookedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void Confirm()
        {
            if (Status != AppointmentStatus.Pending)
                throw new DomainException("Only pending appointments can be confirmed");

            Status = AppointmentStatus.Confirmed;
            ConfirmedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Start()
        {
            if (Status != AppointmentStatus.Confirmed && Status != AppointmentStatus.Pending)
                throw new DomainException($"Cannot start appointment with status: {Status}");

            Status = AppointmentStatus.InProgress;
            StartedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Complete()
        {
            if (Status != AppointmentStatus.InProgress)
                throw new DomainException("Only in-progress appointments can be completed");

            Status = AppointmentStatus.Completed;
            CompletedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Cancel(CancelledBy cancelledBy, string? reason = null)
        {
            if (Status == AppointmentStatus.Completed)
                throw new DomainException("Cannot cancel completed appointment");

            Status = AppointmentStatus.Cancelled;
            CancelledBy = cancelledBy;
            CancellationReason = reason?.Trim();
            CancelledAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void MarkAsNoShow()
        {
            if (Status != AppointmentStatus.Confirmed && Status != AppointmentStatus.Pending)
                throw new DomainException("Invalid status for no-show");

            Status = AppointmentStatus.NoShow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void UpdatePatientNotes(string notes)
        {
            PatientNotes = notes?.Trim();
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
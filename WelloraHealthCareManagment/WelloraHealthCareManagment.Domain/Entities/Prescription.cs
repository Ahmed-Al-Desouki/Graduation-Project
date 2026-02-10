using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class Prescription : BaseEntity
    {
        public Guid AppointmentId { get; private set; }
        public int DoctorId { get; private set; } // ✅ int
        public int PatientId { get; private set; }
        public string PrescriptionNumber { get; private set; } = string.Empty;
        public DateTime IssuedAt { get; private set; }
        public DateTime? ValidUntil { get; private set; }
        public string? SpecialInstructions { get; private set; }
        public string? DoctorSignature { get; private set; }

        public Appointment Appointment { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;
        public Patient Patient { get; private set; } = null!;

        private readonly List<PrescriptionItem> _items = new();
        public IReadOnlyCollection<PrescriptionItem> Items => _items.AsReadOnly();

        private Prescription() { }

        public static Prescription Create(
            Guid appointmentId,
            int doctorId,
            int patientId,
            string prescriptionNumber)
        {
            if (appointmentId == Guid.Empty)
                throw new DomainException("Appointment ID cannot be empty");
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");
            if (patientId <= 0)
                throw new DomainException("Patient ID cannot be empty");
            if (string.IsNullOrWhiteSpace(prescriptionNumber))
                throw new DomainException("Prescription number is required");

            return new Prescription
            {
                Id = Guid.NewGuid(),
                AppointmentId = appointmentId,
                DoctorId = doctorId,
                PatientId = patientId,
                PrescriptionNumber = prescriptionNumber.Trim(),
                IssuedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void AddItem(
            string medicationName,
            string dosage,
            string frequency,
            string duration,
            int quantity,
            string? instructions = null)
        {
            var item = PrescriptionItem.Create(
                Id, medicationName, dosage, frequency, duration, quantity, instructions);

            _items.Add(item);
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetValidity(DateTime validUntil)
        {
            if (validUntil <= IssuedAt)
                throw new DomainException("Valid until must be after issued date");

            ValidUntil = validUntil;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetSpecialInstructions(string? instructions)
        {
            SpecialInstructions = instructions?.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void Sign(string signature)
        {
            if (string.IsNullOrWhiteSpace(signature))
                throw new DomainException("Signature cannot be empty");

            DoctorSignature = signature.Trim();
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
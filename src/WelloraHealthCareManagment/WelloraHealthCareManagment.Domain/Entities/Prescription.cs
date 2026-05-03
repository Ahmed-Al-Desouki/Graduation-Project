using HealthCare_.Models.DoctorModels;
using System.Collections.ObjectModel;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class Prescription : BaseEntity
    {
        public Guid AppointmentId { get; private set; }
        public int DoctorId { get; private set; }
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

        // للوصول الداخلي فقط (مثل في AddItem أو Domain Services)
        protected ICollection<PrescriptionItem> ItemsInternal => _items;

        private Prescription() { } // لـ EF Core

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
            string? instructions = null,
            RepeatFrequency? reminderFrequencyType = null,
            List<DayOfWeek>? weeklyDays = null,
            List<TimeSpan>? dailyDoseTimes = null,
            int? intervalHours = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            TimeSpan? firstDoseTime = null)
        {
            var item = PrescriptionItem.Create(
                Id,
                medicationName,
                dosage,
                frequency,
                duration,
                quantity,
                instructions,
                reminderFrequencyType,
                weeklyDays,
                dailyDoseTimes,
                intervalHours,
                startDate,
                endDate,
                firstDoseTime);

            _items.Add(item);
            UpdatedAt = DateTime.UtcNow; // لو عايز تحديث يدوي
        }

        // لو عايز تضيف overload بدون reminder
        public void AddItem(string medicationName, string dosage, string frequency, string duration, int quantity, string? instructions)
        {
            AddItem(medicationName, dosage, frequency, duration, quantity, instructions);
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
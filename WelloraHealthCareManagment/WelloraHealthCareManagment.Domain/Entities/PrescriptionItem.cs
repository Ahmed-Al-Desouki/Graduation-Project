using WelloraHealthCareManagement.Domain.Exceptions;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class PrescriptionItem : BaseEntity
    {
        public Guid PrescriptionId { get; private set; }
        public string MedicationName { get; private set; } = string.Empty;
        public string? MedicationCode { get; private set; }
        public string Dosage { get; private set; } = string.Empty;
        public string Frequency { get; private set; } = string.Empty;
        public string Duration { get; private set; } = string.Empty;
        public int Quantity { get; private set; }
        public string? Instructions { get; private set; }

        public Prescription Prescription { get; private set; } = null!;

        private PrescriptionItem() { }

        public static PrescriptionItem Create(
            Guid prescriptionId,
            string medicationName,
            string dosage,
            string frequency,
            string duration,
            int quantity,
            string? instructions = null)
        {
            if (prescriptionId == Guid.Empty)
                throw new DomainException("Prescription ID cannot be empty");
            if (string.IsNullOrWhiteSpace(medicationName))
                throw new DomainException("Medication name is required");
            if (string.IsNullOrWhiteSpace(dosage))
                throw new DomainException("Dosage is required");
            if (string.IsNullOrWhiteSpace(frequency))
                throw new DomainException("Frequency is required");
            if (string.IsNullOrWhiteSpace(duration))
                throw new DomainException("Duration is required");
            if (quantity <= 0)
                throw new DomainException("Quantity must be positive");

            return new PrescriptionItem
            {
                Id = Guid.NewGuid(),
                PrescriptionId = prescriptionId,
                MedicationName = medicationName,
                Dosage = dosage,
                Frequency = frequency,
                Duration = duration,
                Quantity = quantity,
                Instructions = instructions,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }
    }
}
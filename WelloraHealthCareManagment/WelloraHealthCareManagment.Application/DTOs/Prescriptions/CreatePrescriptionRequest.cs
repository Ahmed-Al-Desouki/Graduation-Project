namespace WelloraHealthCareManagment.Application.DTOs.Prescriptions
{
    public class CreatePrescriptionRequest
    {
        public Guid AppointmentId { get; set; }
        public DateTime? ValidUntil { get; set; }
        public string? SpecialInstructions { get; set; }
        public List<PrescriptionItemRequest> Items { get; set; } = new();
    }

    public class PrescriptionItemRequest
    {
        public string MedicationName { get; set; } = string.Empty;
        public string? MedicationCode { get; set; }
        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public string? Instructions { get; set; }
    }

    public class PrescriptionResponse
    {
        public Guid PrescriptionId { get; set; }
        public string PrescriptionNumber { get; set; } = string.Empty;
        public DateTime IssuedAt { get; set; }
        public DateTime? ValidUntil { get; set; }
        public List<PrescriptionItemDto> Items { get; set; } = new();
    }

    public class PrescriptionItemDto
    {
        public Guid ItemId { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public string? Instructions { get; set; }
    }
}
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Appointments
{
    public class AppointmentDetailsDto
    {
        public Guid AppointmentId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public AppointmentStatus Status { get; set; }
        public string? PatientNotes { get; set; }

        // Doctor Info
        public int DoctorId { get; set; }
        public string DoctorName { get; set; } = string.Empty;

        // Patient Info
        public int PatientId { get; set; }
        public string PatientName { get; set; } = string.Empty;

        // Medical Record
        public AppointmentMedicalRecordDto? MedicalRecord { get; set; }

        // Prescriptions
        public List<PrescriptionDto> Prescriptions { get; set; } = new();
    }

    public class AppointmentMedicalRecordDto
    {
        public Guid Id { get; set; }
        public string? ChiefComplaint { get; set; }
        public string? VitalSigns { get; set; }
        public string? PhysicalExamination { get; set; }
        public string Diagnosis { get; set; } = string.Empty;
        public string? DiagnosisCode { get; set; }
        public string? TreatmentPlan { get; set; }
        public string? DoctorNotes { get; set; }
        public bool FollowUpRequired { get; set; }
        public DateTime? FollowUpDate { get; set; }
        public string? FollowUpInstructions { get; set; }
    }

    public class PrescriptionDto
    {
        public Guid PrescriptionId { get; set; }
        public string PrescriptionNumber { get; set; } = string.Empty;
        public DateTime IssuedAt { get; set; }
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
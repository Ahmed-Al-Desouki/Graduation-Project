using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class MedicalHistoryAccessLog : BaseEntity
    {
        public Guid AccessGrantId { get; private set; }
        public int DoctorId { get; private set; } // ✅ int
        public int PatientId { get; private set; }
        public DateTime AccessedAt { get; private set; }
        public string AccessType { get; private set; } = string.Empty;
        public string? ResourceAccessed { get; private set; }
        public string? IpAddress { get; private set; }
        public string? UserAgent { get; private set; }

        public MedicalHistoryAccessGrant AccessGrant { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;
        public Patient Patient { get; private set; } = null!;

        private MedicalHistoryAccessLog() { }

        public static MedicalHistoryAccessLog Create(
            Guid accessGrantId,
            int doctorId,
            int patientId,
            string accessType,
            string? resourceAccessed = null,
            string? ipAddress = null,
            string? userAgent = null)
        {
            if (accessGrantId == Guid.Empty)
                throw new DomainException("Access grant ID cannot be empty");
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");
            if (patientId <= 0)
                throw new DomainException("Patient ID cannot be empty");
            if (string.IsNullOrWhiteSpace(accessType))
                throw new DomainException("Access type is required");

            return new MedicalHistoryAccessLog
            {
                Id = Guid.NewGuid(),
                AccessGrantId = accessGrantId,
                DoctorId = doctorId,
                PatientId = patientId,
                AccessedAt = DateTime.UtcNow,
                AccessType = accessType.Trim(),
                ResourceAccessed = resourceAccessed?.Trim(),
                IpAddress = ipAddress?.Trim(),
                UserAgent = userAgent?.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }
    }
}
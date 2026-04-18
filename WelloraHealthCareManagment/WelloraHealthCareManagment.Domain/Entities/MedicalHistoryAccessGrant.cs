using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class MedicalHistoryAccessGrant : BaseEntity
    {
        public int PatientId { get; private set; }
        public int DoctorId { get; private set; } // ✅ int
        public Guid? AppointmentId { get; private set; }
        public GrantType GrantType { get; private set; }
        public DateTime GrantedAt { get; private set; }
        public DateTime? ExpiresAt { get; private set; }
        public DateTime? RevokedAt { get; private set; }
        public string? RevocationReason { get; private set; }

        public bool CanViewMedicalHistory { get; private set; }
        public bool CanViewPrescriptions { get; private set; }
        public bool CanViewLabResults { get; private set; }

        public Patient Patient { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;
        public Appointment? Appointment { get; private set; }

        private readonly List<MedicalHistoryAccessLog> _accessLogs = new();
        public IReadOnlyCollection<MedicalHistoryAccessLog> AccessLogs => _accessLogs.AsReadOnly();

        private MedicalHistoryAccessGrant() { }

        public static MedicalHistoryAccessGrant Create(
            int patientId,
            int doctorId,
            Guid? appointmentId,
            GrantType grantType,
            DateTime? expiresAt,
            bool canViewMedicalHistory = true,
            bool canViewPrescriptions = true,
            bool canViewLabResults = false)
        {
            if (patientId <= 0)
                throw new DomainException("Patient ID cannot be empty");
            if (doctorId <= 0)
                throw new DomainException("Doctor ID must be positive");

            if (grantType == GrantType.Appointment && !appointmentId.HasValue)
                throw new DomainException("Appointment ID is required for appointment-scoped grants");

            if (expiresAt.HasValue && expiresAt <= DateTime.UtcNow)
                throw new DomainException("Expiry date must be in the future");

            return new MedicalHistoryAccessGrant
            {
                Id = Guid.NewGuid(),
                PatientId = patientId,
                DoctorId = doctorId,
                AppointmentId = appointmentId,
                GrantType = grantType,
                GrantedAt = DateTime.UtcNow,
                ExpiresAt = expiresAt,
                CanViewMedicalHistory = canViewMedicalHistory,
                CanViewPrescriptions = canViewPrescriptions,
                CanViewLabResults = canViewLabResults,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public bool IsActive()
        {
            if (RevokedAt.HasValue)
                return false;

            if (ExpiresAt.HasValue && ExpiresAt < DateTime.UtcNow)
                return false;

            return true;
        }

        public void Revoke(string? reason = null)
        {
            if (RevokedAt.HasValue)
                throw new DomainException("Grant is already revoked");

            RevokedAt = DateTime.UtcNow;
            RevocationReason = reason?.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void ExtendExpiry(DateTime newExpiryDate)
        {
            if (RevokedAt.HasValue)
                throw new DomainException("Cannot extend a revoked grant");

            if (newExpiryDate <= DateTime.UtcNow)
                throw new DomainException("New expiry date must be in the future");

            ExpiresAt = newExpiryDate;
            UpdatedAt = DateTime.UtcNow;
        }

        public void UpdatePermissions(
            bool canViewMedicalHistory,
            bool canViewPrescriptions,
            bool canViewLabResults)
        {
            if (RevokedAt.HasValue)
                throw new DomainException("Cannot update a revoked grant. Please create a new one if needed.");

            if (ExpiresAt.HasValue && ExpiresAt < DateTime.UtcNow)
                throw new DomainException("Cannot update an expired grant.");

            CanViewMedicalHistory = canViewMedicalHistory;
            CanViewPrescriptions = canViewPrescriptions;
            CanViewLabResults = canViewLabResults;
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
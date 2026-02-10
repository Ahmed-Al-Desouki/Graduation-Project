using WelloraHealthCareManagement.Domain.Exceptions;

namespace WelloraHealthCareManagement.Domain.Entities
{
 
    /// السجل الطبي للموعد
    public class AppointmentMedicalRecord : BaseEntity
    {
        public Guid AppointmentId { get; private set; }
        public string? ChiefComplaint { get; private set; }
        public string? VitalSigns { get; private set; } // JSON format
        public string? PhysicalExamination { get; private set; }
        public string Diagnosis { get; private set; } = string.Empty;
        public string? DiagnosisCode { get; private set; } // ICD-10
        public string? TreatmentPlan { get; private set; }
        public string? DoctorNotes { get; private set; }
        public bool FollowUpRequired { get; private set; }
        public DateTime? FollowUpDate { get; private set; }
        public string? FollowUpInstructions { get; private set; }

        public Appointment Appointment { get; private set; } = null!;

        private AppointmentMedicalRecord() { }

        public static AppointmentMedicalRecord Create(
            Guid appointmentId,
            string diagnosis)
        {
            if (appointmentId == Guid.Empty)
                throw new DomainException("Appointment ID cannot be empty");
            if (string.IsNullOrWhiteSpace(diagnosis))
                throw new DomainException("Diagnosis is required");

            return new AppointmentMedicalRecord
            {
                Id = Guid.NewGuid(),
                AppointmentId = appointmentId,
                Diagnosis = diagnosis,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void Update(
            string? chiefComplaint,
            string? vitalSigns,
            string? physicalExamination,
            string diagnosis,
            string? diagnosisCode,
            string? treatmentPlan,
            string? doctorNotes)
        {
            if (string.IsNullOrWhiteSpace(diagnosis))
                throw new DomainException("Diagnosis is required");

            ChiefComplaint = chiefComplaint;
            VitalSigns = vitalSigns;
            PhysicalExamination = physicalExamination;
            Diagnosis = diagnosis;
            DiagnosisCode = diagnosisCode;
            TreatmentPlan = treatmentPlan;
            DoctorNotes = doctorNotes;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetFollowUp(DateTime followUpDate, string? instructions)
        {
            FollowUpRequired = true;
            FollowUpDate = followUpDate;
            FollowUpInstructions = instructions;
            UpdatedAt = DateTime.UtcNow;
        }
    }
}
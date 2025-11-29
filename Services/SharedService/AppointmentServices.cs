using HealthCare_.Interfaces;
using HealthCare_.Models.DTOs.AppointmentDTO;
using HealthCare_.Models.DTOs.PatientDTO;
using HealthCare_.Services.Patient;

namespace HealthCare_.Services.SharedService
{
    public class AppointmentService : IAppointmentService
    {
        private readonly HealthCarePlusContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<PatientMedicalProfileService> _logger;

        public AppointmentService(HealthCarePlusContext context,
            IHttpContextAccessor httpContextAccessor,
            ILogger<PatientMedicalProfileService> logger)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        private int GetCurrentUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User.FindFirst("UserID")?.Value
                ?? throw new UnauthorizedAccessException("UserID claim missing.");
            return int.Parse(claim);
        }

        public async Task<List<GetAppointmentDto>> GetPatientAppointmentsAsync(int patientId)
        {
            return await _context.Appointments
                .Where(a => a.PatientID == patientId)
                .Include(a => a.Doctor).ThenInclude(d => d!.User)
                .Select(a => new GetAppointmentDto
                {
                    AppointmentID = a.AppointmentID,
                    AppointmentDate = a.AppointmentDate,
                    Status = a.Status,
                    Type = a.Type ?? string.Empty,
                    Symptoms = a.Symptoms,
                    DoctorName = a.Doctor!.User.FullName,
                    DoctorSpecialization = a.Doctor.Specialization
                })
                .OrderByDescending(a => a.AppointmentDate)
                .ToListAsync();
        }

        public async Task<List<GetAppointmentDto>> GetDoctorAppointmentsAsync(int doctorId)
        {
            return await _context.Appointments
                .Where(a => a.DoctorID == doctorId)
                .Include(a => a.Patient).ThenInclude(p => p!.User)
                .Select(a => new GetAppointmentDto
                {
                    AppointmentID = a.AppointmentID,
                    AppointmentDate = a.AppointmentDate,
                    Status = a.Status,
                    Type = a.Type ?? string.Empty,
                    Symptoms = a.Symptoms,
                    PatientName = a.Patient!.User.FullName,
                    PatientPhone = a.Patient.User.PhoneNumber
                })
                .OrderBy(a => a.AppointmentDate)
                .ToListAsync();
        }

        public async Task<CurrentMedicationDto> UpsertMedicationAsync(int prescriptionId, CurrentMedicationDto request)
        {
            await EnsureHistoryBelongsToCurrentUser(request.HistoryID);
            _logger.LogInformation("Upserting medication '{Medication}' for PrescriptionID: {PrescriptionID}", request.MedicationName, prescriptionId);

            var med = await _context.PrescriptionMeds
                .FirstOrDefaultAsync(m => m.PrescriptionID == prescriptionId && m.MedicationName == request.MedicationName);

            if (med != null)
            {
                med.Dosage = request.Dosage ?? med.Dosage;
                med.Instructions = request.Doseinstruction ?? med.Instructions;
                med.StartDate = request.StartDate ?? med.StartDate;
                med.EndDate = request.EndDate ?? med.EndDate;
                med.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                med = new PrescriptionMed
                {
                    PrescriptionID = prescriptionId,
                    MedicationName = request.MedicationName,
                    Dosage = request.Dosage,
                    Instructions = request.Doseinstruction,
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    CreatedAt = DateTime.UtcNow
                };
                _context.PrescriptionMeds.Add(med);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("Medication upserted successfully: '{Medication}' (ID: {ID})", med.MedicationName, med.ID);

            return new CurrentMedicationDto
            {
                CurrentMedicationID = med.ID,
                HistoryID = request.HistoryID,
                MedicationName = med.MedicationName,
                Dosage = med.Dosage,
                Doseinstruction = med.Instructions,
                StartDate = med.StartDate,
                EndDate = med.EndDate,
                Notes = med.Instructions
            };
        }
        private async Task EnsureHistoryBelongsToCurrentUser(int historyId)
        {
            var userId = GetCurrentUserId();

            var patient = await _context.Patients
                .Include(p => p.MedicalHistory)
                .FirstOrDefaultAsync(p => p.PatientID == userId);

            if (patient == null)
                throw new KeyNotFoundException("Patient not found.");
            if (patient.MedicalHistory == null)
                throw new InvalidOperationException("Medical history not initialized for this patient.");
            if (patient.MedicalHistory.HistoryID != historyId)
                throw new UnauthorizedAccessException("The specified medical history does not belong to the current user.");
        }
    }
}

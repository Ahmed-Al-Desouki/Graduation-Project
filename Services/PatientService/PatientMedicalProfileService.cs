// File: Services/Patient/PatientMedicalProfileService.cs
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Services.Cloud;
using HealthCare_.Models.DTOs.PatientDTO;


namespace HealthCare_.Services.Patient
{

    public class PatientMedicalProfileService : IMedicalProfileService
    {
        private readonly HealthCarePlusContext _context;
        private readonly FileUploadService _fileUploadService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<PatientMedicalProfileService> _logger;

        public PatientMedicalProfileService(
            HealthCarePlusContext context,
            FileUploadService fileUploadService,
            IHttpContextAccessor httpContextAccessor,
            ILogger<PatientMedicalProfileService> logger)
        {
            _context = context;
            _fileUploadService = fileUploadService;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        private int GetCurrentUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User.FindFirst("UserID")?.Value
                ?? throw new UnauthorizedAccessException("UserID claim missing.");
            return int.Parse(claim);
        }

        public async Task<MedicalProfileResponse> GetMedicalProfileAsync()
        {
            var userId = GetCurrentUserId();
            _logger.LogInformation("Fetching medical profile for PatientID: {PatientID}", userId);

            var patient = await _context.Patients
              .Include(p => p.User)
                  .ThenInclude(u => u.ProfileImagePath)
              .Include(p => p.MedicalHistory!)
                  .ThenInclude(mh => mh.Files)                   
              .Include(p => p.MedicalHistory!)
                  .ThenInclude(mh => mh.MedicalRecords!)
                      .ThenInclude(mr => mr.Doctor!)
                          .ThenInclude(d => d.User)
              .Include(p => p.Appointments!)
                  .ThenInclude(a => a.Doctor!)
                      .ThenInclude(d => d.User)
              .Include(p => p.Appointments!)
                  .ThenInclude(a => a.Prescription!)                  
                      .ThenInclude(p => p.Medications)
              .FirstOrDefaultAsync(p => p.PatientID == userId)
              ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? throw new InvalidOperationException("Medical history not initialized.");

            return new MedicalProfileResponse
            {
                PatientID = patient.PatientID,
                MedicalHistoryID = patient.MedicalHistory.HistoryID,
                FullName = patient.User.FullName,
                Email = patient.User.Email ?? "",
                ProfileImageUrl = patient.User.ProfileImagePath?.FileUrl,
                DateOfBirth = history.DateOfBirth,
                Gender = history.Gender,
                CurrentLocation = history.CurrentLocation,
                BloodType = history.BloodType,
                Allergies = history.Allergies,
                ChronicConditions = history.ChronicConditions,
                Height = history.Height,
                Weight = history.Weight,
                
                LabTests = history.Files
                    .Where(f => f.CategoryValue == "LabTest")
                    .Select(f => new FileDto
                    {
                        FileID = f.FileID,
                        FileUrl = f.FileUrl,
                        FileType = f.FileType,
                        FileSize = f.FileSize,
                        Description = f.Description,
                        UploadedAt = f.UploadedAt
                    }).ToList(),

                RadiologyFiles = history.Files
                    .Where(f => f.CategoryValue == "Radiology")
                    .Select(f => new FileDto
                    {
                        FileID = f.FileID,
                        FileUrl = f.FileUrl,
                        FileType = f.FileType,
                        FileSize = f.FileSize,
                        UploadedAt = f.UploadedAt,
                        Description = f.Description
                    }).ToList(),

                PastAppointments = patient.Appointments
                    .Where(a => a.AppointmentDate < DateTime.UtcNow && a.Status == "Completed")
                    .Select(a => new PastAppointmentDto
                    {
                        AppointmentID = a.AppointmentID,
                        AppointmentDate = a.AppointmentDate,
                        DoctorName = a.Doctor?.User?.FullName ?? "Unknown",
                        Specialty = a.Doctor?.Specialization ?? "N/A",
                        Symptoms = a.Symptoms ?? "",
                        Status = a.Status,
                        Prescription = a.Prescription != null ? new PrescriptionSummaryDto
                        {
                            PrescriptionID = a.Prescription.PrescriptionID,
                            PrescriptionDate = a.Prescription.PrescriptionDate,
                            GeneralInstructions = a.Prescription.GeneralInstructions ?? "",
                            Medications = a.Prescription.Medications.Select(m => new MedicationDto
                            {
                                MedicationName = m.MedicationName,
                                Dosage = m.Dosage ?? "",
                                Instructions = m.Instructions ?? ""
                            }).ToList()
                        } : null
                    }).OrderByDescending(a => a.AppointmentDate).ToList(),

                MedicalRecords = history.MedicalRecords
                .Select(mr => new MedicalRecordDto
                {
                    RecordID = mr.RecordID,
                    VisitDate = mr.VisitDate,
                    DoctorName = mr.Doctor?.User?.FullName ?? "Unknown",
                    Diagnosis = mr.Diagnosis ?? "",
                    Symptoms = mr.Symptoms ?? "",
                    Notes = mr.Notes ?? "",

                    // الأدوية من الـ Prescription المرتبط بالموعد
                    Medications = _context.Appointments
                        .Where(a => a.AppointmentDate == mr.VisitDate && a.PatientID == patient.PatientID)
                        .SelectMany(a => a.Prescription!.Medications)
                        .Select(pm => new PrescriptionMedDto
                        {
                            MedicationName = pm.MedicationName,
                            Dosage = pm.Dosage ?? "",
                            Instructions = pm.Instructions ?? ""
                        })
                        .ToList()
                })
                .OrderByDescending(r => r.VisitDate)
                .ToList()
            };
        }

        public async Task<MedicalProfileResponse> UpdateMedicalProfileAsync(Models.DTOs.PatientDot.UpdateMedicalProfileRequest request)
        {
            var userId = GetCurrentUserId();
            _logger.LogInformation("Updating medical profile for PatientID: {PatientID}", userId);

            var patient = await _context.Patients
                .Include(p => p.MedicalHistory!).ThenInclude(mh => mh.Files)
                .FirstOrDefaultAsync(p => p.PatientID == userId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? new MedicalHistory { PatientID = userId };

            // Update fields only if provided
            if (request.BloodType != null) history.BloodType = request.BloodType;
            if (request.Allergies != null) history.Allergies = request.Allergies;
            if (request.ChronicConditions != null) history.ChronicConditions = request.ChronicConditions;
            if (request.Height.HasValue) history.Height = request.Height.Value;
            if (request.Weight.HasValue) history.Weight = request.Weight.Value;
            if (request.DateOfBirth.HasValue) history.DateOfBirth = request.DateOfBirth.Value;
            if (request.Gender != null) history.Gender = request.Gender;
            if (request.CurrentLocation != null) history.CurrentLocation = request.CurrentLocation;

            history.UpdatedAt = DateTime.UtcNow;

            if (history.HistoryID == 0)
            {
                _context.MedicalHistories.Add(history);
                patient.MedicalHistory = history;
            }


            await _context.SaveChangesAsync();
            _logger.LogInformation("Medical profile updated successfully for PatientID: {PatientID}", userId);

            return await GetMedicalProfileAsync(); // Return fresh data
        }
    }
}
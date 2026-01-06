// Services/Patient/MedicalProfileService.cs
using HealthCare_.Interfaces.Patient;
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using HealthCare_.Services.Shared;

namespace HealthCare_.Services.Patient
{
    public class MedicalProfileService : IMedicalProfileService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;
        private readonly ISurgeryService _surgeryService;
        private readonly IFamilyHistoryService _familyHistoryService;
        private readonly ISocialHistoryService _socialHistoryService;
        private readonly ISelfMedicationService _selfMedicationService;
        private readonly ICurrentMedicationService _currentMedicationService;
        private readonly ILogger<MedicalProfileService> _logger;

        public MedicalProfileService(
            HealthCarePlusContext context,
            AuthHelperService authHelper,
            ILogger<MedicalProfileService> logger,
            ISurgeryService surgeryService,
            IFamilyHistoryService familyHistoryService,
            ISocialHistoryService socialHistoryService,
            ISelfMedicationService selfMedicationService,
            ICurrentMedicationService currentMedicationService
        )
        {
            _context = context;
            _authHelper = authHelper;
            _logger = logger;
            _surgeryService = surgeryService;
            _familyHistoryService = familyHistoryService;
            _socialHistoryService = socialHistoryService;
            _selfMedicationService = selfMedicationService;
            _currentMedicationService = currentMedicationService;
        }

        public async Task<MedicalProfileResponse> GetMedicalProfileAsync()
        {
            var userId = _authHelper.GetCurrentUserId(); // استخدمنا الـ helper
            _logger.LogInformation("Fetching medical profile for PatientID: {PatientID}", userId);

            var patient = await _context.Patients
                .AsNoTracking()
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
                .FirstOrDefaultAsync(p => p.PatientID == userId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? throw new InvalidOperationException("Medical history not initialized.");

            var labTests = history.Files
                .Where(f => f.CategoryValue == "LabTest")
                .Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    Description = f.Description,
                    UploadedAt = f.UploadedAt
                }).ToList();

            var radiologyFiles = history.Files
                .Where(f => f.CategoryValue == "Radiology")
                .Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    UploadedAt = f.UploadedAt,
                    Description = f.Description
                }).ToList();

            var pastAppointments = patient.Appointments
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
                        Medications = a.Prescription.Medications.Select(m => new CurrentMedicationDto
                        {
                            MedicationName = m.MedicationName
                        }).ToList()
                    } : null
                }).OrderByDescending(a => a.AppointmentDate).ToList();

            var medicalRecords = history.MedicalRecords
                .Select(mr => new MedicalRecordDto
                {
                    RecordID = mr.RecordID,
                    VisitDate = mr.VisitDate,
                    DoctorName = mr.Doctor?.User?.FullName ?? "Unknown",
                    Diagnosis = mr.Diagnosis ?? "",
                    Symptoms = mr.Symptoms ?? "",
                    Notes = mr.Notes ?? "",
                }).OrderByDescending(r => r.VisitDate).ToList();

            _logger.LogInformation("Fetched complete medical profile for PatientID: {PatientID}", userId);

            return new MedicalProfileResponse
            {
                PatientID = patient.PatientID,
                MedicalHistoryID = history.HistoryID,
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
                LabTests = labTests,
                RadiologyFiles = radiologyFiles,
                PastAppointments = pastAppointments,
                MedicalRecords = medicalRecords,
                Surgeries = new List<SurgeryDto>(),
                FamilyHistory = new List<FamilyHistoryDto>(),
                SocialHistory = new List<SocialHistoryDto>(),
                PatientSelfMedications = new List<SelfMedicationDto>(),
                CurrentMedications = new List<CurrentMedicationDto>()
            };
        }
        public async Task<MedicalProfileResponse> GetCompleteMedicalProfileAsync(int patientId)
        {
            _logger.LogInformation("Fetching complete medical profile for PatientID: {PatientID}", patientId);

            var patient = await _context.Patients
                .AsNoTracking()
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
                .FirstOrDefaultAsync(p => p.PatientID == patientId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? throw new InvalidOperationException("Medical history not initialized.");

            // -----------------------------
            // Files (Lab & Radiology)
            // -----------------------------
            var labTests = history.Files
                .Where(f => f.CategoryValue == "LabTest")
                .Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    Description = f.Description,
                    UploadedAt = f.UploadedAt
                }).ToList();

            var radiologyFiles = history.Files
                .Where(f => f.CategoryValue == "Radiology")
                .Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    UploadedAt = f.UploadedAt,
                    Description = f.Description
                }).ToList();

            // -----------------------------
            // Appointments & Prescriptions
            // -----------------------------
            var pastAppointments = patient.Appointments
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
                        Medications = a.Prescription.Medications.Select(m => new CurrentMedicationDto
                        {
                            MedicationName = m.MedicationName
                        }).ToList()
                    } : null
                }).OrderByDescending(a => a.AppointmentDate).ToList();

            // -----------------------------
            // Medical Records
            // -----------------------------
            var medicalRecords = history.MedicalRecords
                .Select(mr => new MedicalRecordDto
                {
                    RecordID = mr.RecordID,
                    VisitDate = mr.VisitDate,
                    DoctorName = mr.Doctor?.User?.FullName ?? "Unknown",
                    Diagnosis = mr.Diagnosis ?? "",
                    Symptoms = mr.Symptoms ?? "",
                    Notes = mr.Notes ?? "",
                }).OrderByDescending(r => r.VisitDate).ToList();

            // -----------------------------
            // Other sections via services
            // -----------------------------
            var surgeries = await _surgeryService.GetSurgeriesForShareAsync(history.HistoryID);
            var familyHistory = await _familyHistoryService.GetFamilyHistoryForShareAsync(history.HistoryID);
            var socialHistory = await _socialHistoryService.GetSocialHistoryForShareAsync(history.HistoryID);
            var selfMedications = await _selfMedicationService.GetSelfMedicationsForShareAsync(patient.PatientID);
            var currentMedications = await _currentMedicationService.GetCurrentMedicationsForShareAsync(history.HistoryID);

            // -----------------------------
            // Construct final response
            // -----------------------------
            return new MedicalProfileResponse
            {
                PatientID = patient.PatientID,
                MedicalHistoryID = history.HistoryID,
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
                LabTests = labTests,
                RadiologyFiles = radiologyFiles,
                PastAppointments = pastAppointments,
                MedicalRecords = medicalRecords,
                Surgeries = surgeries,
                FamilyHistory = familyHistory,
                SocialHistory = socialHistory,
                PatientSelfMedications = selfMedications,
                CurrentMedications = currentMedications
            };
        }
        public async Task<MedicalProfileResponse> UpdateMedicalProfileAsync(UpdateMedicalProfileRequest request)
        {
            var userId = _authHelper.GetCurrentUserId();
            _logger.LogInformation("Updating medical profile for PatientID: {PatientID}", userId);

            var patient = await _context.Patients
                .Include(p => p.MedicalHistory!).ThenInclude(mh => mh.Files)
                .FirstOrDefaultAsync(p => p.PatientID == userId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? new MedicalHistory { PatientID = userId };

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

            return await GetMedicalProfileAsync();
        }
    }
}

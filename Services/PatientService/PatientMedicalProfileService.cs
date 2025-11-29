// File: Services/Patient/PatientMedicalProfileService.cs
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Services.Cloud;
using HealthCare_.Models.DTOs.PatientDTO;
using Microsoft.EntityFrameworkCore;

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
                .FirstOrDefaultAsync(p => p.PatientID == userId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory ?? throw new InvalidOperationException("Medical history not initialized.");

            // Fetch files
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

            // Past appointments without medications
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

            // Medical records without medications
            var medicalRecords = history.MedicalRecords
                .Select(mr => new MedicalRecordDto
                {
                    RecordID = mr.RecordID,
                    VisitDate = mr.VisitDate,
                    DoctorName = mr.Doctor?.User?.FullName ?? "Unknown",
                    Diagnosis = mr.Diagnosis ?? "",
                    Symptoms = mr.Symptoms ?? "",
                    Notes = mr.Notes ?? "",
                    //Medications = mr.MedicalRecords != null ? null : null // Remove full meds to avoid duplication
                }).OrderByDescending(r => r.VisitDate).ToList();

            // Surgeries, family, social history
            var surgeries = await _context.Surgeries
                .Where(s => s.HistoryID == history.HistoryID && !s.IsDeleted)
                .Select(s => new SurgeryDto
                {
                    SurgeryID = s.SurgeryID,
                    Name = s.Name,
                    Date = s.Date,
                    Notes = s.Notes,
                    Complications = s.Complications
                }).ToListAsync();

            var familyHistory = await _context.FamilyHistoryEntries
                .Where(f => f.HistoryID == history.HistoryID && !f.IsDeleted)

                .Select(f => new FamilyHistoryDto
                {
                    FamilyHistoryID = f.FamilyHistoryID,
                    Condition = f.Condition,
                    Relative = f.Relative,
                    OnsetAge = f.OnsetAge,
                    Notes = f.Notes,
                    IsVerified = f.IsVerified
                }).ToListAsync();

            var selfMeds = await _context.PatientSelfMedications
                .Where(m => m.PatientID == userId && !m.IsDeleted)

                .Select(m => new SelfMedicationDto
                {
                    ID = m.ID,
                    MedicationName = m.MedicationName,
                    Dosage = m.Dosage,
                    Instructions = m.Instructions,
                    StartDate = m.StartDate,
                    EndDate = m.EndDate
                }).ToListAsync();

            var socialHistory = await _context.SocialHistories
                .Where(s => s.HistoryID == history.HistoryID && !s.IsDeleted)
                .Select(s => new SocialHistoryDto
                {
                    SocialHistoryID = s.SocialHistoryID,
                    SmokingStatus = s.SmokingStatus,
                    SmokingDetails = s.SmokingDetails,
                    AlcoholUse = s.AlcoholUse,
                    DrugUse = s.DrugUse,
                    Occupation = s.Occupation,
                    Exercise = s.Exercise,
                    Notes = s.Notes
                }).ToListAsync();

            // Current medications (full details)
            var currentMedications = await GetCurrentMedicationsAsync(history.HistoryID);

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
                Surgeries = surgeries,
                FamilyHistory = familyHistory,
                SocialHistory = socialHistory,
                CurrentMedications = currentMedications,
                PatientSelfMedications = selfMeds
            };
        }



        public async Task<MedicalProfileResponse> UpdateMedicalProfileAsync(UpdateMedicalProfileRequest request)
        {
            var userId = GetCurrentUserId();
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

        public async Task<SelfMedicationDto> UpsertSelfMedicationAsync(CreateSelfMedicationRequest request)
        {
            var userId = GetCurrentUserId();

            _logger.LogInformation(
                "Upserting self medication for PatientID: {PatientID}, MedicationID: {MedicationID}",
                userId,
                request.SelfMedicationID
            );

            PatientSelfMedication? selfMed = null;

            // ✅ لو جاي ID → Update
            if (request.SelfMedicationID.HasValue)
            {
                selfMed = await _context.PatientSelfMedications.FirstOrDefaultAsync(m =>
                    m.ID == request.SelfMedicationID.Value &&
                    m.PatientID == userId);
            }

            if (selfMed != null)
            {
                // UPDATE
                selfMed.MedicationName = request.MedicationName ?? selfMed.MedicationName;
                selfMed.Dosage = request.Dosage ?? selfMed.Dosage;
                selfMed.Instructions = request.Instructions ?? selfMed.Instructions;
                selfMed.StartDate = request.StartDate ?? selfMed.StartDate;
                selfMed.EndDate = request.EndDate ?? selfMed.EndDate;
                selfMed.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                // INSERT
                selfMed = new PatientSelfMedication
                {
                    PatientID = userId,
                    MedicationName = request.MedicationName,
                    Dosage = request.Dosage,
                    Instructions = request.Instructions,
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    CreatedAt = DateTime.UtcNow
                };

                _context.PatientSelfMedications.Add(selfMed);
            }

            await _context.SaveChangesAsync();

            return new SelfMedicationDto
            {
                ID = selfMed.ID,
                MedicationName = selfMed.MedicationName,
                Dosage = selfMed.Dosage,
                Instructions = selfMed.Instructions,
                StartDate = selfMed.StartDate,
                EndDate = selfMed.EndDate
            };
        }



        public async Task<List<CurrentMedicationDto>> GetCurrentMedicationsAsync(int historyId)
        {
            var today = DateTime.UtcNow.Date;
            await EnsureHistoryBelongsToCurrentUser(historyId);
            _logger.LogInformation("Fetching current medications for HistoryID: {HistoryID}", historyId);

            var meds = await _context.Prescriptions
                .Where(pr => pr.Patient.MedicalHistory != null && pr.Patient.MedicalHistory.HistoryID == historyId)
                .SelectMany(pr => pr.Medications, (pr, pm) => new { Prescription = pr, Med = pm })
                .Where(x =>
                    ((x.Med.StartDate == null || x.Med.StartDate.Value.Date <= today)
                     && (x.Med.EndDate == null || x.Med.EndDate.Value.Date >= today))
                    ||
                    ((x.Med.StartDate == null && x.Med.EndDate == null)
                     && (x.Prescription.PrescriptionDate.Date <= today)
                     && (x.Prescription.EndDate == null || x.Prescription.EndDate.Value.Date >= today)))
                .Select(x => new CurrentMedicationDto
                {
                    CurrentMedicationID = x.Med.ID,
                    HistoryID = historyId,
                    MedicationName = x.Med.MedicationName,
                    Dosage = x.Med.Dosage,
                    Doseinstruction = x.Med.Instructions,
                    Frequency = x.Med.DosingSchedules.Any() ? string.Join(", ", x.Med.DosingSchedules.Select(ds => ds.DailyTime.ToString(@"hh\:mm"))) : null,
                    StartDate = x.Med.StartDate ?? x.Prescription.PrescriptionDate,
                    EndDate = x.Med.EndDate ?? x.Prescription.EndDate,
                    Notes = x.Med.Instructions,
                    IsOverTheCounter = false
                }).ToListAsync();

            _logger.LogInformation("Fetched {Count} current medications for HistoryID: {HistoryID}", meds.Count, historyId);
            return meds;
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


        public async Task<SurgeryDto> UpsertSurgeryAsync(CreateSurgeryRequest request)
        {
            await EnsureHistoryBelongsToCurrentUser(request.HistoryID);
            _logger.LogInformation("Upserting surgery '{Surgery}' for HistoryID: {HistoryID}", request.Name, request.HistoryID);

            var surgery = request.SurgeryID.HasValue
              ? await _context.Surgeries.FirstOrDefaultAsync(s =>
                  s.SurgeryID == request.SurgeryID.Value &&
                  s.HistoryID == request.HistoryID)
              : null;

            if (surgery != null)
            {
                //  UPDATE
                surgery.Name = request.Name ?? surgery.Name;
                surgery.Date = request.Date ?? surgery.Date;
                surgery.Notes = request.Notes ?? surgery.Notes;
                surgery.Complications = request.Complications ?? surgery.Complications;
                surgery.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                surgery = new Surgery
                {
                    HistoryID = request.HistoryID,
                    Name = request.Name,
                    Date = request.Date,
                    Notes = request.Notes,
                    Complications = request.Complications,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Surgeries.Add(surgery);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("Surgery upserted successfully: '{Surgery}' (ID: {ID})", surgery.Name, surgery.SurgeryID);

            return new SurgeryDto
            {
                SurgeryID = surgery.SurgeryID,
                Name = surgery.Name,
                Date = surgery.Date,
                Notes = surgery.Notes,
                Complications = surgery.Complications
            };
        }

        public async Task<FamilyHistoryDto> UpsertFamilyHistoryAsync(CreateFamilyHistoryRequest request)
        {
            await EnsureHistoryBelongsToCurrentUser(request.HistoryID);

            _logger.LogInformation(
                "Upserting family history for HistoryID: {HistoryID}, FamilyHistoryID: {FamilyHistoryID}",
                request.HistoryID,
                request.FamilyHistoryID
            );

            FamilyHistoryEntry? record = null;

            //  لو جاي ID → Update
            if (request.FamilyHistoryID.HasValue)
            {
                record = await _context.FamilyHistoryEntries.FirstOrDefaultAsync(f =>
                    f.FamilyHistoryID == request.FamilyHistoryID.Value &&
                    f.HistoryID == request.HistoryID);
            }

            if (record != null)
            {
                // ✅ UPDATE
                record.Condition = request.Condition ?? record.Condition;
                record.Relative = request.Relative ?? record.Relative;
                record.OnsetAge = request.OnsetAge ?? record.OnsetAge;
                record.Notes = request.Notes ?? record.Notes;
                record.IsVerified = request.IsVerified;
                record.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                // ✅ INSERT
                record = new FamilyHistoryEntry
                {
                    HistoryID = request.HistoryID,
                    Condition = request.Condition,
                    Relative = request.Relative,
                    OnsetAge = request.OnsetAge,
                    Notes = request.Notes,
                    IsVerified = request.IsVerified,
                    CreatedAt = DateTime.UtcNow
                };

                _context.FamilyHistoryEntries.Add(record);
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Family history upserted successfully (ID: {ID})",
                record.FamilyHistoryID
            );

            return new FamilyHistoryDto
            {
                FamilyHistoryID = record.FamilyHistoryID,
                Condition = record.Condition,
                Relative = record.Relative,
                OnsetAge = record.OnsetAge,
                Notes = record.Notes,
                IsVerified = record.IsVerified
            };
        }


        public async Task<SocialHistoryDto> UpsertSocialHistoryAsync(UpsertSocialHistoryRequest request)
        {
            await EnsureHistoryBelongsToCurrentUser(request.HistoryID);
            _logger.LogInformation("Upserting social history for HistoryID: {HistoryID}", request.HistoryID);

            var record = await _context.SocialHistories
                .FirstOrDefaultAsync(s => s.HistoryID == request.HistoryID);

            if (record != null)
            {
                record.SmokingStatus = request.SmokingStatus;
                record.SmokingDetails = request.SmokingDetails ?? record.SmokingDetails;
                record.AlcoholUse = request.AlcoholUse;
                record.DrugUse = request.DrugUse ?? record.DrugUse;
                record.Occupation = request.Occupation ?? record.Occupation;
                record.Exercise = request.Exercise ?? record.Exercise;
                record.Notes = request.Notes ?? record.Notes;
                record.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                record = new SocialHistory
                {
                    HistoryID = request.HistoryID,
                    SmokingStatus = request.SmokingStatus,
                    SmokingDetails = request.SmokingDetails,
                    AlcoholUse = request.AlcoholUse,
                    DrugUse = request.DrugUse,
                    Occupation = request.Occupation,
                    Exercise = request.Exercise,
                    Notes = request.Notes,
                    CreatedAt = DateTime.UtcNow
                };
                _context.SocialHistories.Add(record);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("Social history upserted successfully (ID: {ID})", record.SocialHistoryID);

            return new SocialHistoryDto
            {
                SocialHistoryID = record.SocialHistoryID,
                SmokingStatus = record.SmokingStatus,
                SmokingDetails = record.SmokingDetails,
                AlcoholUse = record.AlcoholUse,
                DrugUse = record.DrugUse,
                Occupation = record.Occupation,
                Exercise = record.Exercise,
                Notes = record.Notes
            };
        }
        public async Task SoftDeleteSurgeryAsync(int surgeryId, int historyId)
        {
            await EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete Surgery. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                surgeryId, historyId
            );

            var surgery = await _context.Surgeries.FirstOrDefaultAsync(s =>
                s.SurgeryID == surgeryId &&
                s.HistoryID == historyId &&
                !s.IsDeleted);

            if (surgery == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Surgery Not Found. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                    surgeryId, historyId
                );
                throw new KeyNotFoundException("Surgery not found.");
            }

            surgery.IsDeleted = true;
            surgery.DeletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Surgery Soft Deleted Successfully. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                surgeryId, historyId
            );
        }

        public async Task SoftDeleteFamilyHistoryAsync(int familyHistoryId, int historyId)
        {
            await EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete FamilyHistory. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                familyHistoryId, historyId
            );

            var record = await _context.FamilyHistoryEntries.FirstOrDefaultAsync(f =>
                f.FamilyHistoryID == familyHistoryId &&
                f.HistoryID == historyId &&
                !f.IsDeleted);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Family History Not Found. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                    familyHistoryId, historyId
                );
                throw new KeyNotFoundException("Family history not found.");
            }

            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Family History Soft Deleted Successfully. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                familyHistoryId, historyId
            );
        }

        public async Task SoftDeleteSelfMedicationAsync(int selfMedicationId)
        {
            var userId = GetCurrentUserId();

            _logger.LogInformation(
                "Attempting Soft Delete SelfMedication. ID: {ID}, PatientID: {PatientID}",
                selfMedicationId, userId
            );

            var selfMed = await _context.PatientSelfMedications.FirstOrDefaultAsync(m =>
                m.ID == selfMedicationId &&
                m.PatientID == userId &&
                !m.IsDeleted);

            if (selfMed == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Self Medication Not Found. ID: {ID}, PatientID: {PatientID}",
                    selfMedicationId, userId
                );
                throw new KeyNotFoundException("Self medication not found.");
            }

            selfMed.IsDeleted = true;
            selfMed.DeletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Self Medication Soft Deleted Successfully. ID: {ID}, PatientID: {PatientID}",
                selfMedicationId, userId
            );
        }

        public async Task SoftDeleteSocialHistoryAsync(int socialHistoryId, int historyId)
        {
            await EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete SocialHistory. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                socialHistoryId, historyId
            );

            var record = await _context.SocialHistories.FirstOrDefaultAsync(s =>
                s.SocialHistoryID == socialHistoryId &&
                s.HistoryID == historyId &&
                !s.IsDeleted);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Social History Not Found. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                    socialHistoryId, historyId
                );
                throw new KeyNotFoundException("Social history not found.");
            }

            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Social History Soft Deleted Successfully. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                socialHistoryId, historyId
            );
        }


    }
}

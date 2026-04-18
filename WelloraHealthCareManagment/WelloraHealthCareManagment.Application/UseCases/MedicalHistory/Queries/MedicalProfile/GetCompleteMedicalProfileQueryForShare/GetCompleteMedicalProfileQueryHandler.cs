// Application/UseCases/MedicalProfile/Queries/GetCompleteMedicalProfile/GetCompleteMedicalProfileQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare
{
    public class GetCompleteMedicalProfileQueryHandler
    {
        private readonly IMedicalHistoryRepository _patientRepository;
        private readonly IMedicalFileRepository _medicalFileRepository;
        private readonly ILogger<GetCompleteMedicalProfileQueryHandler> _logger;

        // استخدام الـ "ForShare" Handlers
        private readonly GetSurgeriesForShareQueryHandler _getSurgeriesForShareHandler;
        private readonly GetFamilyHistoryForShareQueryHandler _getFamilyHistoryForShareHandler;
        private readonly GetSocialHistoryForShareQueryHandler _getSocialHistoryForShareHandler;
        private readonly GetSelfMedicationsForShareQueryHandler _getSelfMedicationsForShareHandler;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly GetCurrentMedicationsQueryHandler _getCurrentMedicationsHandler;

        //private readonly GetCurrentMedicationsForShareQueryHandler _getCurrentMedicationsForShareHandler;

        public GetCompleteMedicalProfileQueryHandler(
            IMedicalHistoryRepository patientRepository,
            IMedicalFileRepository medicalFileRepository,
            ILogger<GetCompleteMedicalProfileQueryHandler> logger,
            GetSurgeriesForShareQueryHandler getSurgeriesForShareHandler,
            GetFamilyHistoryForShareQueryHandler getFamilyHistoryForShareHandler,
            GetSocialHistoryForShareQueryHandler getSocialHistoryForShareHandler,
            GetSelfMedicationsForShareQueryHandler getSelfMedicationsForShareHandler,
            IAppointmentRepository appointmentRepository,
            GetCurrentMedicationsQueryHandler getCurrentMedicationsHandler)
            //GetCurrentMedicationsForShareQueryHandler getCurrentMedicationsForShareHandler)
        {
            _patientRepository = patientRepository;
            _medicalFileRepository = medicalFileRepository;
            _logger = logger;
            _getSurgeriesForShareHandler = getSurgeriesForShareHandler;
            _getFamilyHistoryForShareHandler = getFamilyHistoryForShareHandler;
            _getSocialHistoryForShareHandler = getSocialHistoryForShareHandler;
            _getSelfMedicationsForShareHandler = getSelfMedicationsForShareHandler;
            _appointmentRepository = appointmentRepository;
            _getCurrentMedicationsHandler = getCurrentMedicationsHandler;
            //_getCurrentMedicationsForShareHandler = getCurrentMedicationsForShareHandler;
        }

        public async Task<MedicalProfileResponse> HandleAsync(
            GetCompleteMedicalProfileQuery query,
            CancellationToken ct = default)
        {
            _logger.LogInformation(
                "Fetching complete medical profile for PatientID: {PatientID}",
                query.PatientId);

            // 1. Get patient complete data
            var patient = await _patientRepository.GetCompletePatientDataAsync(query.PatientId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory
                ?? throw new InvalidOperationException("Medical history not initialized.");

            // 2. Get files
            var labTests = await _medicalFileRepository.GetLabTestsByHistoryIdAsync(history.HistoryID);
            var radiologyFiles = await _medicalFileRepository.GetRadiologyFilesByHistoryIdAsync(history.HistoryID);

            var currentMedications = await _getCurrentMedicationsHandler.HandleAsync(
                new GetCurrentMedicationsQuery(query.PatientId), ct);

            // 5. استخدام الـ "ForShare" Handlers
            var surgeries = await _getSurgeriesForShareHandler.HandleAsync(
                new GetSurgeriesForShareQuery(query.PatientId));

            var familyHistory = await _getFamilyHistoryForShareHandler.HandleAsync(
                new GetFamilyHistoryForShareQuery(history.HistoryID));

            var socialHistory = await _getSocialHistoryForShareHandler.HandleAsync(
                new GetSocialHistoryForShareQuery(query.PatientId));

            var selfMedications = await _getSelfMedicationsForShareHandler.HandleAsync(
                new GetSelfMedicationsForShareQuery(query.PatientId));

            var completedAppointments = await _appointmentRepository
                .GetCompletedByPatientIdAsync(query.PatientId, ct);

            var pastAppointments = completedAppointments.Select(a => new PastAppointmentDto
            {
                AppointmentId = a.Id,
                AppointmentDate = a.TimeSlot.SlotDate,
                StartTime = a.TimeSlot.StartTime,
                EndTime = a.TimeSlot.EndTime,
                Status = a.Status,
                PatientNotes = a.PatientNotes,
                CompletedAt = a.CompletedAt,

                DoctorId = a.DoctorId,
                DoctorName = $"Dr. {a.Doctor?.User?.FullName ?? "(Unknown)"}",
                Specialization = a.Doctor?.Specialization ?? "N/A",

                PatientId = a.PatientId,
                PatientName = a.Patient?.User?.FullName ?? "Patient (Unknown)",

                CanViewMedicalHistory = false,
                CanViewPrescriptions = false,
                CanViewLabResults = false,

                MedicalRecord = a.MedicalRecord == null ? null : new AppointmentMedicalRecordDto
                {
                    Id = a.MedicalRecord.Id,
                    ChiefComplaint = a.MedicalRecord.ChiefComplaint,
                    VitalSigns = a.MedicalRecord.VitalSigns,
                    PhysicalExamination = a.MedicalRecord.PhysicalExamination,
                    Diagnosis = a.MedicalRecord.Diagnosis,
                    DiagnosisCode = a.MedicalRecord.DiagnosisCode,
                    TreatmentPlan = a.MedicalRecord.TreatmentPlan,
                    DoctorNotes = a.MedicalRecord.DoctorNotes,
                    FollowUpRequired = a.MedicalRecord.FollowUpRequired,
                    FollowUpDate = a.MedicalRecord.FollowUpDate,
                    FollowUpInstructions = a.MedicalRecord.FollowUpInstructions
                },

                Prescriptions = a.Prescriptions.Select(p => new PrescriptionDto
                {
                    PrescriptionId = p.Id,
                    PrescriptionNumber = p.PrescriptionNumber,
                    IssuedAt = p.IssuedAt,
                    Items = p.Items.Select(i => new PrescriptionItemDto
                    {
                        ItemId = i.Id,
                        MedicationName = i.MedicationName,
                        Dosage = i.Dosage,
                        Frequency = i.Frequency,
                        Duration = i.Duration,
                        Quantity = i.Quantity,
                        Instructions = i.Instructions
                    }).ToList()
                }).ToList()

            }).ToList();

            // 6. Build response
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
                Allergies = history.Allergies != null
                    ? JsonSerializer.Deserialize<List<string>>(history.Allergies) ?? new()
                    : new(),
                ChronicConditions = history.ChronicConditions != null
                    ? JsonSerializer.Deserialize<List<string>>(history.ChronicConditions) ?? new()
                    : new(),
                Height = (double)history.Height,
                Weight = (double)history.Weight,
                LabTests = labTests.Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    Description = f.Description,
                    UploadedAt = f.UploadedAt
                }).ToList(),
                RadiologyFiles = radiologyFiles.Select(f => new FileDto
                {
                    FileID = f.FileID,
                    FileUrl = f.FileUrl,
                    FileType = f.FileType,
                    FileSize = f.FileSize,
                    Description = f.Description,
                    UploadedAt = f.UploadedAt
                }).ToList(),
                PastAppointments = pastAppointments,
                Surgeries = surgeries,
                FamilyHistory = familyHistory,
                SocialHistory = socialHistory,
                PatientSelfMedications = selfMedications,
                CurrentMedications = currentMedications
            };
        }
    }
}
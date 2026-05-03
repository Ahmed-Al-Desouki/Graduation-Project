// Application/UseCases/MedicalProfile/Queries/GetMedicalProfile/GetMedicalProfileQueryHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetMedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetMedicalProfile
{
    public class GetMedicalProfileQueryHandler
    {
        private readonly IMedicalHistoryRepository _patientRepository;
        private readonly IMedicalFileRepository _medicalFileRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<GetMedicalProfileQueryHandler> _logger;

        // استخدام الـ Handlers بدل الـ Services
        private readonly GetSurgeriesQueryHandler _getSurgeriesHandler;
        private readonly GetFamilyHistoryQueryHandler _getFamilyHistoryHandler;
        private readonly GetSocialHistoryQueryHandler _getSocialHistoryHandler;
        private readonly GetSelfMedicationsQueryHandler _getSelfMedicationsHandler;
        //private readonly GetCurrentMedicationsQueryHandler _getCurrentMedicationsHandler;

        public GetMedicalProfileQueryHandler(
            IMedicalHistoryRepository patientRepository,
            IMedicalFileRepository medicalFileRepository,
            ICurrentUserService currentUserService,
            ILogger<GetMedicalProfileQueryHandler> logger,
            GetSurgeriesQueryHandler getSurgeriesHandler,
            GetFamilyHistoryQueryHandler getFamilyHistoryHandler,
            GetSocialHistoryQueryHandler getSocialHistoryHandler,
            GetSelfMedicationsQueryHandler getSelfMedicationsHandler)
            //GetCurrentMedicationsQueryHandler getCurrentMedicationsHandler)
        {
            _patientRepository = patientRepository;
            _medicalFileRepository = medicalFileRepository;
            _currentUserService = currentUserService;
            _logger = logger;
            _getSurgeriesHandler = getSurgeriesHandler;
            _getFamilyHistoryHandler = getFamilyHistoryHandler;
            _getSocialHistoryHandler = getSocialHistoryHandler;
            _getSelfMedicationsHandler = getSelfMedicationsHandler;
            //_getCurrentMedicationsHandler = getCurrentMedicationsHandler;
        }

        public async Task<MedicalProfileResponse> HandleAsync(GetMedicalProfileQuery query)
        {
            var userId = _currentUserService.GetCurrentUserId();

            _logger.LogInformation(
                "Fetching medical profile for PatientID: {PatientID}",
                userId);

            // 1. Get patient complete data
            var patient = await _patientRepository.GetCompletePatientDataAsync(userId)
                ?? throw new KeyNotFoundException("Patient not found.");

            var history = patient.MedicalHistory
                ?? throw new InvalidOperationException("Medical history not initialized.");

            // 2. Get files
            var labTests = await _medicalFileRepository.GetLabTestsByHistoryIdAsync(history.HistoryID);
            var radiologyFiles = await _medicalFileRepository.GetRadiologyFilesByHistoryIdAsync(history.HistoryID);

            // 3. Map appointments
            //var pastAppointments = patient.Appointments
            //    .Where(a => a.AppointmentDate < DateTime.UtcNow && a.Status == "Completed")
            //    .Select(a => new PastAppointmentDto
            //    {
            //        AppointmentID = a.AppointmentID,
            //        AppointmentDate = a.AppointmentDate,
            //        DoctorName = a.Doctor?.User?.FullName ?? "Unknown",
            //        Specialty = a.Doctor?.Specialization ?? "N/A",
            //        Symptoms = a.Symptoms ?? "",
            //        Status = a.Status,
            //        Prescription = a.Prescription != null ? new PrescriptionSummaryDto
            //        {
            //            PrescriptionID = a.Prescription.PrescriptionID,
            //            PrescriptionDate = a.Prescription.PrescriptionDate,
            //            GeneralInstructions = a.Prescription.GeneralInstructions ?? "",
            //            Medications = a.Prescription.Medications.Select(m => new CurrentMedicationDto
            //            {
            //                MedicationName = m.MedicationName
            //            }).ToList()
            //        } : null
            //    }).OrderByDescending(a => a.AppointmentDate).ToList();

            // 4. Map medical records
            //var medicalRecords = history.MedicalRecords
            //    .Select(mr => new MedicalRecordDto
            //    {
            //        RecordID = mr.RecordID,
            //        VisitDate = mr.VisitDate,
            //        DoctorName = mr.Doctor?.User?.FullName ?? "Unknown",
            //        Diagnosis = mr.Diagnosis ?? "",
            //        Symptoms = mr.Symptoms ?? "",
            //        Notes = mr.Notes ?? ""
            //    }).OrderByDescending(r => r.VisitDate).ToList();

            // 5. استخدام الـ Handlers بدل الـ Services
            var surgeries = await _getSurgeriesHandler.HandleAsync(
                new GetSurgeriesQuery(history.HistoryID));

            var familyHistory = await _getFamilyHistoryHandler.HandleAsync(
                new GetFamilyHistoryQuery(history.HistoryID));

            var socialHistory = await _getSocialHistoryHandler.HandleAsync(
                new GetSocialHistoryQuery(history.HistoryID));

            var selfMedications = await _getSelfMedicationsHandler.HandleAsync(
                new GetSelfMedicationsQuery(history.HistoryID));

            //var currentMedications = await _getCurrentMedicationsHandler.HandleAsync(
            //    new GetCurrentMedicationsQuery(history.HistoryID));

            _logger.LogInformation(
                "Fetched complete medical profile for PatientID: {PatientID}",
                userId);

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
                //PastAppointments = pastAppointments,
                //MedicalRecords = medicalRecords,
                Surgeries = surgeries,
                FamilyHistory = familyHistory,
                SocialHistory = socialHistory,
                PatientSelfMedications = selfMedications,
                //CurrentMedications = currentMedications
            };
        }
    }
}
// Application/UseCases/MedicalProfile/Queries/GetCompleteMedicalProfile/GetCompleteMedicalProfileQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

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
        //private readonly GetCurrentMedicationsForShareQueryHandler _getCurrentMedicationsForShareHandler;

        public GetCompleteMedicalProfileQueryHandler(
            IMedicalHistoryRepository patientRepository,
            IMedicalFileRepository medicalFileRepository,
            ILogger<GetCompleteMedicalProfileQueryHandler> logger,
            GetSurgeriesForShareQueryHandler getSurgeriesForShareHandler,
            GetFamilyHistoryForShareQueryHandler getFamilyHistoryForShareHandler,
            GetSocialHistoryForShareQueryHandler getSocialHistoryForShareHandler,
            GetSelfMedicationsForShareQueryHandler getSelfMedicationsForShareHandler)
            //GetCurrentMedicationsForShareQueryHandler getCurrentMedicationsForShareHandler)
        {
            _patientRepository = patientRepository;
            _medicalFileRepository = medicalFileRepository;
            _logger = logger;
            _getSurgeriesForShareHandler = getSurgeriesForShareHandler;
            _getFamilyHistoryForShareHandler = getFamilyHistoryForShareHandler;
            _getSocialHistoryForShareHandler = getSocialHistoryForShareHandler;
            _getSelfMedicationsForShareHandler = getSelfMedicationsForShareHandler;
            //_getCurrentMedicationsForShareHandler = getCurrentMedicationsForShareHandler;
        }

        public async Task<MedicalProfileResponse> HandleAsync(GetCompleteMedicalProfileQuery query)
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

            // 5. استخدام الـ "ForShare" Handlers
            var surgeries = await _getSurgeriesForShareHandler.HandleAsync(
                new GetSurgeriesForShareQuery(query.PatientId));

            var familyHistory = await _getFamilyHistoryForShareHandler.HandleAsync(
                new GetFamilyHistoryForShareQuery(query.PatientId));

            var socialHistory = await _getSocialHistoryForShareHandler.HandleAsync(
                new GetSocialHistoryForShareQuery(query.PatientId));

            var selfMedications = await _getSelfMedicationsForShareHandler.HandleAsync(
                new GetSelfMedicationsForShareQuery(query.PatientId));

            //var currentMedications = await _getCurrentMedicationsForShareHandler.HandleAsync(
            //    new GetCurrentMedicationsForShareQuery(history.HistoryID));

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
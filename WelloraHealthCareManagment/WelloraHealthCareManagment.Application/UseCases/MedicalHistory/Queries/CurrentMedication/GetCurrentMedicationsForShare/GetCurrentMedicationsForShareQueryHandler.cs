// Application/UseCases/MedicalHistory/Queries/GetCurrentMedicationsForShare/GetCurrentMedicationsForShareQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare
{
    public class GetCurrentMedicationsForShareQueryHandler
    {
        private readonly IPrescriptionRepository _prescriptionRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;

        public GetCurrentMedicationsForShareQueryHandler(
            IPrescriptionRepository prescriptionRepository,
            ICurrentMedicationRepository medicalHistoryRepository)
        {
            _prescriptionRepository = prescriptionRepository;
            _currentMedicationRepository = medicalHistoryRepository;
        }

        public async Task<List<CurrentMedicationDto>> HandleAsync(
            GetCurrentMedicationsForShareQuery query)
        {
            // 1. Get patient ID from medical history
            var patientId = await _currentMedicationRepository
                .GetPatientIdByHistoryIdAsync(query.MedicalHistoryId);

            if (!patientId.HasValue || patientId.Value == 0)
            {
                throw new KeyNotFoundException("Medical history not found.");
            }

            // 2. Get medications
            var medications = await _prescriptionRepository
                .GetMedicationsByPatientIdAsync(patientId.Value);

            // 3. Map to DTOs
            var result = medications.Select(med => new CurrentMedicationDto
            {
                CurrentMedicationID = med.ID,
                HistoryID = query.MedicalHistoryId,
                MedicationName = med.MedicationName,
                Dosage = med.Dosage,
                StartDate = med.StartDate,
                EndDate = med.EndDate,
                Notes = med.Instructions
            }).ToList();

            return result;
        }
    }
}
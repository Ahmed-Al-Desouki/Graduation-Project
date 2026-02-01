// Application/UseCases/MedicalHistory/SelfMedication/Queries/GetSelfMedicationsForShare/GetSelfMedicationsForShareQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare
{
    public class GetSelfMedicationsForShareQueryHandler
    {
        private readonly ISelfMedicationRepository _selfMedicationRepository;

        public GetSelfMedicationsForShareQueryHandler(
            ISelfMedicationRepository selfMedicationRepository)
        {
            _selfMedicationRepository = selfMedicationRepository;
        }

        public async Task<List<SelfMedicationDto>> HandleAsync(
            GetSelfMedicationsForShareQuery query)
        {
            // Get self medications (no authorization needed for share)
            var medications = await _selfMedicationRepository
                .GetByPatientIdAsync(query.PatientId);

            // Map to DTOs
            var result = medications.Select(m => new SelfMedicationDto
            {
                ID = m.ID,
                MedicationName = m.MedicationName,
                Dosage = m.Dosage,
                Instructions = m.Instructions,
                StartDate = m.StartDate,
                EndDate = m.EndDate
            }).ToList();

            return result;
        }
    }
}
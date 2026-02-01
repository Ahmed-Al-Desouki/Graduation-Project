// Application/UseCases/MedicalHistory/Surgery/Queries/GetSurgeriesForShare/GetSurgeriesForShareQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare
{
    public class GetSurgeriesForShareQueryHandler
    {
        private readonly ISurgeryRepository _surgeryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;

        public GetSurgeriesForShareQueryHandler(
            ISurgeryRepository surgeryRepository,
            ICurrentMedicationRepository currentMedicationRepository)
        {
            _surgeryRepository = surgeryRepository;
            _currentMedicationRepository = currentMedicationRepository;
        }

        public async Task<List<SurgeryDto>> HandleAsync(
            GetSurgeriesForShareQuery query)
        {
            // 1. Get history ID from patient ID
            var historyId = await _currentMedicationRepository
                .GetHistoryIdByPatientIdAsync(query.PatientId);

            if (!historyId.HasValue || historyId.Value == 0)
            {
                return new List<SurgeryDto>(); // No history found
            }

            // 2. Get surgeries
            var surgeries = await _surgeryRepository
                .GetByHistoryIdAsync(historyId.Value);

            // 3. Map to DTOs
            var result = surgeries.Select(s => new SurgeryDto
            {
                SurgeryID = s.SurgeryID,
                Name = s.Name,
                Date = s.Date,
                Notes = s.Notes,
                Complications = s.Complications
            }).ToList();

            return result;
        }
    }
}
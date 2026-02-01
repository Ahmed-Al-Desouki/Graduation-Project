// Application/UseCases/MedicalHistory/SocialHistory/Queries/GetSocialHistoryForShare/GetSocialHistoryForShareQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare
{
    public class GetSocialHistoryForShareQueryHandler
    {
        private readonly ISocialHistoryRepository _socialHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;

        public GetSocialHistoryForShareQueryHandler(
            ISocialHistoryRepository socialHistoryRepository,
            ICurrentMedicationRepository currentMedicationRepository)
        {
            _socialHistoryRepository = socialHistoryRepository;
            _currentMedicationRepository = currentMedicationRepository;
        }

        public async Task<List<SocialHistoryDto>> HandleAsync(
            GetSocialHistoryForShareQuery query)
        {
            // 1. Get history ID from patient ID
            var historyId = await _currentMedicationRepository
                .GetHistoryIdByPatientIdAsync(query.PatientId);

            if (!historyId.HasValue || historyId.Value == 0)
            {
                return new List<SocialHistoryDto>(); // No history found
            }

            // 2. Get social history entries
            var entries = await _socialHistoryRepository
                .GetByHistoryIdAsync(historyId.Value);

            // 3. Map to DTOs
            var result = entries.Select(s => new SocialHistoryDto
            {
                SocialHistoryID = s.SocialHistoryID,
                SmokingStatus = s.SmokingStatus,
                SmokingDetails = s.SmokingDetails,
                AlcoholUse = s.AlcoholUse,
                DrugUse = s.DrugUse,
                Occupation = s.Occupation,
                Exercise = s.Exercise,
                Notes = s.Notes
            }).ToList();

            return result;
        }
    }
}
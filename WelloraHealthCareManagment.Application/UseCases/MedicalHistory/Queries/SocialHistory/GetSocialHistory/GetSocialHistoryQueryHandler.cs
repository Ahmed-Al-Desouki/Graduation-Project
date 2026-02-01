using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory
{
    public class GetSocialHistoryQueryHandler
    {
        private readonly ISocialHistoryRepository _socialHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;

        public GetSocialHistoryQueryHandler(
            ISocialHistoryRepository socialHistoryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService)
        {
            _socialHistoryRepository = socialHistoryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
        }

        public async Task<List<SocialHistoryDto>> HandleAsync(GetSocialHistoryQuery query)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            // 2. Validate that history belongs to current user
            var belongsToUser = await _currentMedicationRepository
                .HistoryBelongsToPatientAsync(query.HistoryId, userId);

            if (!belongsToUser)
            {
                throw new UnauthorizedAccessException(
                    "The specified medical history does not belong to the current user.");
            }

            // 3. Get social history entries
            var entries = await _socialHistoryRepository
                .GetByHistoryIdAsync(query.HistoryId);

            // 4. Map to DTOs
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
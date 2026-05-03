// Application/UseCases/MedicalHistory/FamilyHistory/Queries/GetFamilyHistory/GetFamilyHistoryQueryHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistory
{
    public class GetFamilyHistoryQueryHandler
    {
        private readonly IFamilyHistoryRepository _familyHistoryRepository;
        private readonly ICurrentMedicationRepository _CurrentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;

        public GetFamilyHistoryQueryHandler(
            IFamilyHistoryRepository familyHistoryRepository,
            ICurrentMedicationRepository CurrentMedicationRepository,
            ICurrentUserService currentUserService)
        {
            _familyHistoryRepository = familyHistoryRepository;
            _CurrentMedicationRepository = CurrentMedicationRepository;
            _currentUserService = currentUserService;
        }

        public async Task<List<FamilyHistoryDto>> HandleAsync(GetFamilyHistoryQuery query)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            // 2. Validate that history belongs to current user
            var belongsToUser = await _CurrentMedicationRepository
                .HistoryBelongsToPatientAsync(query.HistoryId, userId);

            if (!belongsToUser)
            {
                throw new UnauthorizedAccessException(
                    "The specified medical history does not belong to the current user.");
            }

            // 3. Get family history entries
            var entries = await _familyHistoryRepository
                .GetByHistoryIdAsync(query.HistoryId);

            // 4. Map to DTOs
            var result = entries.Select(f => new FamilyHistoryDto
            {
                FamilyHistoryID = f.FamilyHistoryID,
                Condition = f.Condition,
                Relative = f.Relative,
                OnsetAge = f.OnsetAge,
                Notes = f.Notes,
                IsVerified = f.IsVerified
            }).ToList();

            return result;
        }
    }
}
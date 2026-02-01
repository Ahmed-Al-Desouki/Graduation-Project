using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare
{
    public class GetFamilyHistoryForShareQueryHandler
    {
        private readonly IFamilyHistoryRepository _familyHistoryRepository;

        public GetFamilyHistoryForShareQueryHandler(
            IFamilyHistoryRepository familyHistoryRepository)
        {
            _familyHistoryRepository = familyHistoryRepository;
        }

        public async Task<List<FamilyHistoryDto>> HandleAsync(
            GetFamilyHistoryForShareQuery query)
        {
            // Get family history entries (no authorization needed for share)
            var entries = await _familyHistoryRepository
                .GetByHistoryIdAsync(query.MedicalHistoryId);

            // Map to DTOs
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
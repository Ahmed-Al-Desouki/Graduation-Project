// Application/UseCases/MedicalHistory/Surgery/Queries/GetSurgeries/GetSurgeriesQueryHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries
{
    public class GetSurgeriesQueryHandler
    {
        private readonly ISurgeryRepository _surgeryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;

        public GetSurgeriesQueryHandler(
            ISurgeryRepository surgeryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService)
        {
            _surgeryRepository = surgeryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
        }

        public async Task<List<SurgeryDto>> HandleAsync(GetSurgeriesQuery query)
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

            // 3. Get surgeries
            var surgeries = await _surgeryRepository
                .GetByHistoryIdAsync(query.HistoryId);

            // 4. Map to DTOs
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
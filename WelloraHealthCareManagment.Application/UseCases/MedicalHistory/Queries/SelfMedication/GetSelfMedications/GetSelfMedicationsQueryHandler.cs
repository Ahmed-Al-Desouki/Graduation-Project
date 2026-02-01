// Application/UseCases/MedicalHistory/SelfMedication/Queries/GetSelfMedications/GetSelfMedicationsQueryHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications
{
    public class GetSelfMedicationsQueryHandler
    {
        private readonly ISelfMedicationRepository _selfMedicationRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;

        public GetSelfMedicationsQueryHandler(
            ISelfMedicationRepository selfMedicationRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService)
        {
            _selfMedicationRepository = selfMedicationRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
        }

        public async Task<List<SelfMedicationDto>> HandleAsync(GetSelfMedicationsQuery query)
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

            // 3. Get self medications
            var medications = await _selfMedicationRepository
                .GetByPatientAndHistoryIdAsync(userId, query.HistoryId);

            // 4. Map to DTOs
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
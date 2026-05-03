// Application/UseCases/MedicalHistory/FamilyHistory/Commands/SoftDeleteFamilyHistory/SoftDeleteFamilyHistoryCommandHandler.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.SoftDeleteFamilyHistory
{
    public class SoftDeleteFamilyHistoryCommandHandler
    {
        private readonly IFamilyHistoryRepository _familyHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SoftDeleteFamilyHistoryCommandHandler> _logger;

        public SoftDeleteFamilyHistoryCommandHandler(
            IFamilyHistoryRepository familyHistoryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<SoftDeleteFamilyHistoryCommandHandler> logger)
        {
            _familyHistoryRepository = familyHistoryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task HandleAsync(SoftDeleteFamilyHistoryCommand command)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            // 2. Validate that history belongs to current user
            var belongsToUser = await _currentMedicationRepository
                .HistoryBelongsToPatientAsync(command.HistoryId, userId);

            if (!belongsToUser)
            {
                throw new UnauthorizedAccessException(
                    "The specified medical history does not belong to the current user.");
            }

            _logger.LogInformation(
                "Attempting Soft Delete FamilyHistory. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                command.FamilyHistoryId, command.HistoryId
            );

            // 3. Get the record
            var record = await _familyHistoryRepository
                .GetByIdAsync(command.FamilyHistoryId, command.HistoryId);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Family History Not Found. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                    command.FamilyHistoryId, command.HistoryId
                );
                throw new KeyNotFoundException("Family history not found.");
            }

            // 4. Soft delete
            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;

            await _familyHistoryRepository.SoftDeleteAsync(record);

            _logger.LogInformation(
                "Family History Soft Deleted Successfully. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                command.FamilyHistoryId, command.HistoryId
            );
        }
    }
}
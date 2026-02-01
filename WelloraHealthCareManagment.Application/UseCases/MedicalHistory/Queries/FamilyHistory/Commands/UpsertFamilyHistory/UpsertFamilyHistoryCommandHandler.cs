// Application/UseCases/MedicalHistory/FamilyHistory/Commands/UpsertFamilyHistory/UpsertFamilyHistoryCommandHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.UpsertFamilyHistory
{
    public class UpsertFamilyHistoryCommandHandler
    {
        private readonly IFamilyHistoryRepository _familyHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UpsertFamilyHistoryCommandHandler> _logger;

        public UpsertFamilyHistoryCommandHandler(
            IFamilyHistoryRepository familyHistoryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<UpsertFamilyHistoryCommandHandler> logger)
        {
            _familyHistoryRepository = familyHistoryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task<FamilyHistoryDto> HandleAsync(UpsertFamilyHistoryCommand command)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            // 2. Validate that history belongs to current user
            var belongsToUser = await _currentMedicationRepository
                .HistoryBelongsToPatientAsync(command.HistoryID, userId);

            if (!belongsToUser)
            {
                throw new UnauthorizedAccessException(
                    "The specified medical history does not belong to the current user.");
            }

            _logger.LogInformation(
                "Upserting family history for HistoryID: {HistoryID}, FamilyHistoryID: {FamilyHistoryID}",
                command.HistoryID,
                command.FamilyHistoryID
            );

            FamilyHistoryEntry? record = null;

            // 3. Check if update or create
            if (command.FamilyHistoryID.HasValue)
            {
                record = await _familyHistoryRepository
                    .GetByIdAsync(command.FamilyHistoryID.Value, command.HistoryID);
            }

            if (record != null)
            {
                // Update existing
                record.Condition = command.Condition ?? record.Condition;
                record.Relative = command.Relative ?? record.Relative;
                record.OnsetAge = command.OnsetAge ?? record.OnsetAge;
                record.Notes = command.Notes ?? record.Notes;
                record.IsVerified = command.IsVerified;
                record.UpdatedAt = DateTime.UtcNow;

                await _familyHistoryRepository.UpdateAsync(record);
            }
            else
            {
                // Create new
                record = new FamilyHistoryEntry
                {
                    HistoryID = command.HistoryID,
                    Condition = command.Condition,
                    Relative = command.Relative,
                    OnsetAge = command.OnsetAge,
                    Notes = command.Notes,
                    IsVerified = command.IsVerified,
                    CreatedAt = DateTime.UtcNow
                };

                record = await _familyHistoryRepository.AddAsync(record);
            }

            _logger.LogInformation(
                "Family history upserted successfully (ID: {ID})",
                record.FamilyHistoryID
            );

            // 4. Return DTO
            return new FamilyHistoryDto
            {
                FamilyHistoryID = record.FamilyHistoryID,
                Condition = record.Condition,
                Relative = record.Relative,
                OnsetAge = record.OnsetAge,
                Notes = record.Notes,
                IsVerified = record.IsVerified
            };
        }
    }
}
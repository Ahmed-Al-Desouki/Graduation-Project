// Application/UseCases/MedicalHistory/SocialHistory/Commands/UpsertSocialHistory/UpsertSocialHistoryCommandHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.Commands.UpsertSocialHistory
{
    public class UpsertSocialHistoryCommandHandler
    {
        private readonly ISocialHistoryRepository _socialHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UpsertSocialHistoryCommandHandler> _logger;

        public UpsertSocialHistoryCommandHandler(
            ISocialHistoryRepository socialHistoryRepository,
            ICurrentMedicationRepository medicalHistoryRepository,
            ICurrentUserService currentUserService,
            ILogger<UpsertSocialHistoryCommandHandler> logger)
        {
            _socialHistoryRepository = socialHistoryRepository;
            _currentMedicationRepository = medicalHistoryRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task<SocialHistoryDto> HandleAsync(UpsertSocialHistoryCommand command)
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
                "Upserting social history for HistoryID: {HistoryID}",
                command.HistoryID
            );

            // 3. Check if record exists
            var record = await _socialHistoryRepository
                .GetSingleByHistoryIdAsync(command.HistoryID);

            if (record != null)
            {
                // Update existing
                record.SmokingStatus = command.SmokingStatus;
                record.SmokingDetails = command.SmokingDetails ?? record.SmokingDetails;
                record.AlcoholUse = command.AlcoholUse;
                record.DrugUse = command.DrugUse ?? record.DrugUse;
                record.Occupation = command.Occupation ?? record.Occupation;
                record.Exercise = command.Exercise ?? record.Exercise;
                record.Notes = command.Notes ?? record.Notes;
                record.UpdatedAt = DateTime.UtcNow;

                await _socialHistoryRepository.UpdateAsync(record);
            }
            else
            {
                // Create new
                record = new HealthCare_.Models.PatientModels.MedicalHistoryModels.SocialHistory
                {
                    HistoryID = command.HistoryID,
                    SmokingStatus = command.SmokingStatus,
                    SmokingDetails = command.SmokingDetails,
                    AlcoholUse = command.AlcoholUse,
                    DrugUse = command.DrugUse,
                    Occupation = command.Occupation,
                    Exercise = command.Exercise,
                    Notes = command.Notes,
                    CreatedAt = DateTime.UtcNow
                };

                record = await _socialHistoryRepository.AddAsync(record);
            }

            _logger.LogInformation(
                "Social history upserted successfully (ID: {ID})",
                record.SocialHistoryID
            );

            // 4. Return DTO
            return new SocialHistoryDto
            {
                SocialHistoryID = record.SocialHistoryID,
                SmokingStatus = record.SmokingStatus,
                SmokingDetails = record.SmokingDetails,
                AlcoholUse = record.AlcoholUse,
                DrugUse = record.DrugUse,
                Occupation = record.Occupation,
                Exercise = record.Exercise,
                Notes = record.Notes
            };
        }
    }
}
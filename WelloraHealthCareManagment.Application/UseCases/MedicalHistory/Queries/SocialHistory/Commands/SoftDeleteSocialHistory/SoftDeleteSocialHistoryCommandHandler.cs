// Application/UseCases/MedicalHistory/SocialHistory/Commands/SoftDeleteSocialHistory/SoftDeleteSocialHistoryCommandHandler.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistory.Commands.SoftDeleteSocialHistory;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistory.Commands.SoftDeleteSocialHistory
{
    public class SoftDeleteSocialHistoryCommandHandler
    {
        private readonly ISocialHistoryRepository _socialHistoryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SoftDeleteSocialHistoryCommandHandler> _logger;

        public SoftDeleteSocialHistoryCommandHandler(
            ISocialHistoryRepository socialHistoryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<SoftDeleteSocialHistoryCommandHandler> logger)
        {
            _socialHistoryRepository = socialHistoryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task HandleAsync(SoftDeleteSocialHistoryCommand command)
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
                "Attempting Soft Delete SocialHistory. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                command.SocialHistoryId, command.HistoryId
            );

            // 3. Get the record
            var record = await _socialHistoryRepository
                .GetByIdAsync(command.SocialHistoryId, command.HistoryId);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Social History Not Found. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                    command.SocialHistoryId, command.HistoryId
                );
                throw new KeyNotFoundException("Social history not found.");
            }

            // 4. Soft delete
            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;

            await _socialHistoryRepository.SoftDeleteAsync(record);

            _logger.LogInformation(
                "Social History Soft Deleted Successfully. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                command.SocialHistoryId, command.HistoryId
            );
        }
    }
}
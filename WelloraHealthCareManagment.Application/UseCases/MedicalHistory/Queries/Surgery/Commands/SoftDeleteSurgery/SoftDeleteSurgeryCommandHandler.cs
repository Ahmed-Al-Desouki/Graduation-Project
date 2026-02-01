// Application/UseCases/MedicalHistory/Surgery/Commands/SoftDeleteSurgery/SoftDeleteSurgeryCommandHandler.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.SoftDeleteSurgery;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.SoftDeleteSurgery
{
    public class SoftDeleteSurgeryCommandHandler
    {
        private readonly ISurgeryRepository _surgeryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SoftDeleteSurgeryCommandHandler> _logger;

        public SoftDeleteSurgeryCommandHandler(
            ISurgeryRepository surgeryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<SoftDeleteSurgeryCommandHandler> logger)
        {
            _surgeryRepository = surgeryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task HandleAsync(SoftDeleteSurgeryCommand command)
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
                "Attempting Soft Delete Surgery. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                command.SurgeryId, command.HistoryId
            );

            // 3. Get the record
            var surgery = await _surgeryRepository
                .GetByIdAsync(command.SurgeryId, command.HistoryId);

            if (surgery == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Surgery Not Found. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                    command.SurgeryId, command.HistoryId
                );
                throw new KeyNotFoundException("Surgery not found.");
            }

            // 4. Soft delete
            surgery.IsDeleted = true;
            surgery.DeletedAt = DateTime.UtcNow;

            await _surgeryRepository.SoftDeleteAsync(surgery);

            _logger.LogInformation(
                "Surgery Soft Deleted Successfully. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                command.SurgeryId, command.HistoryId
            );
        }
    }
}
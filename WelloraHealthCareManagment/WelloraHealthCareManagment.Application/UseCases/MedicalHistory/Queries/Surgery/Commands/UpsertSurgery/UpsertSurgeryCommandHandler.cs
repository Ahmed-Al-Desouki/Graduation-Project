// Application/UseCases/MedicalHistory/Surgery/Commands/UpsertSurgery/UpsertSurgeryCommandHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;


namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.UpsertSurgery
{
    public class UpsertSurgeryCommandHandler
    {
        private readonly ISurgeryRepository _surgeryRepository;
        private readonly ICurrentMedicationRepository _currentMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UpsertSurgeryCommandHandler> _logger;

        public UpsertSurgeryCommandHandler(
            ISurgeryRepository surgeryRepository,
            ICurrentMedicationRepository currentMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<UpsertSurgeryCommandHandler> logger)
        {
            _surgeryRepository = surgeryRepository;
            _currentMedicationRepository = currentMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task<SurgeryDto> HandleAsync(UpsertSurgeryCommand command)
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
                "Upserting surgery '{Surgery}' for HistoryID: {HistoryID}",
                command.Name,
                command.HistoryID
            );

            HealthCare_.Models.PatientModels.MedicalHistoryModels.Surgery? surgery = null;

            // 3. Check if update or create
            if (command.SurgeryID.HasValue)
            {
                surgery = await _surgeryRepository
                    .GetByIdAsync(command.SurgeryID.Value, command.HistoryID);
            }

            if (surgery != null)
            {
                // Update existing
                surgery.Name = command.Name ?? surgery.Name;
                surgery.Date = command.Date ?? surgery.Date;
                surgery.Notes = command.Notes ?? surgery.Notes;
                surgery.Complications = command.Complications ?? surgery.Complications;
                surgery.UpdatedAt = DateTime.UtcNow;

                await _surgeryRepository.UpdateAsync(surgery);
            }
            else
            {
                // Create new
                surgery = new HealthCare_.Models.PatientModels.MedicalHistoryModels.Surgery
                {
                    HistoryID = command.HistoryID,
                    Name = command.Name,
                    Date = command.Date,
                    Notes = command.Notes,
                    Complications = command.Complications,
                    CreatedAt = DateTime.UtcNow
                };

                surgery = await _surgeryRepository.AddAsync(surgery);
            }

            _logger.LogInformation(
                "Surgery upserted successfully: '{Surgery}' (ID: {ID})",
                surgery.Name,
                surgery.SurgeryID
            );

            // 4. Return DTO
            return new SurgeryDto
            {
                SurgeryID = surgery.SurgeryID,
                Name = surgery.Name,
                Date = surgery.Date,
                Notes = surgery.Notes,
                Complications = surgery.Complications
            };
        }
    }
}
// Application/UseCases/MedicalHistory/SelfMedication/Commands/UpsertSelfMedication/UpsertSelfMedicationCommandHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.UpsertSelfMedication
{
    public class UpsertSelfMedicationCommandHandler
    {
        private readonly ISelfMedicationRepository _selfMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UpsertSelfMedicationCommandHandler> _logger;

        public UpsertSelfMedicationCommandHandler(
            ISelfMedicationRepository selfMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<UpsertSelfMedicationCommandHandler> logger)
        {
            _selfMedicationRepository = selfMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task<SelfMedicationDto> HandleAsync(UpsertSelfMedicationCommand command)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            _logger.LogInformation(
                "Upserting self medication for PatientID: {PatientID}, MedicationID: {MedicationID}",
                userId,
                command.SelfMedicationID
            );

            PatientSelfMedication? selfMed = null;

            // 2. Check if update or create
            if (command.SelfMedicationID.HasValue)
            {
                selfMed = await _selfMedicationRepository
                    .GetByIdAsync(command.SelfMedicationID.Value, userId, command.HistoryID);
            }

            if (selfMed != null)
            {
                // Update existing
                selfMed.PatientID = command.PatientId;
                selfMed.HistoryID = command.HistoryID;
                selfMed.MedicationName = command.MedicationName ?? selfMed.MedicationName;
                selfMed.Dosage = command.Dosage ?? selfMed.Dosage;
                selfMed.Instructions = command.Instructions ?? selfMed.Instructions;
                selfMed.StartDate = command.StartDate ?? selfMed.StartDate;
                selfMed.EndDate = command.EndDate ?? selfMed.EndDate;
                selfMed.UpdatedAt = DateTime.UtcNow;

                await _selfMedicationRepository.UpdateAsync(selfMed);
            }
            else
            {
                // Create new
                selfMed = new PatientSelfMedication
                {
                    PatientID = userId,
                    HistoryID = command.HistoryID,
                    MedicationName = command.MedicationName,
                    Dosage = command.Dosage,
                    Instructions = command.Instructions,
                    StartDate = command.StartDate,
                    EndDate = command.EndDate,
                    CreatedAt = DateTime.UtcNow
                };

                selfMed = await _selfMedicationRepository.AddAsync(selfMed);
            }

            _logger.LogInformation(
                "Self medication upserted successfully (ID: {ID})",
                selfMed.ID
            );

            // 3. Return DTO
            return new SelfMedicationDto
            {
                ID = selfMed.ID,
                MedicationName = selfMed.MedicationName,
                Dosage = selfMed.Dosage,
                Instructions = selfMed.Instructions,
                StartDate = selfMed.StartDate,
                EndDate = selfMed.EndDate
            };
        }
    }
}
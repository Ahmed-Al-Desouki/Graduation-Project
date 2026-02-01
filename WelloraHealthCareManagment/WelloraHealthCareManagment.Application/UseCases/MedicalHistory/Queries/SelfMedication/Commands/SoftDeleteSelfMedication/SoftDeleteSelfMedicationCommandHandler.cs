// Application/UseCases/MedicalHistory/SelfMedication/Commands/SoftDeleteSelfMedication/SoftDeleteSelfMedicationCommandHandler.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.SoftDeleteSelfMedication;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.SoftDeleteSelfMedication
{
    public class SoftDeleteSelfMedicationCommandHandler
    {
        private readonly ISelfMedicationRepository _selfMedicationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SoftDeleteSelfMedicationCommandHandler> _logger;

        public SoftDeleteSelfMedicationCommandHandler(
            ISelfMedicationRepository selfMedicationRepository,
            ICurrentUserService currentUserService,
            ILogger<SoftDeleteSelfMedicationCommandHandler> logger)
        {
            _selfMedicationRepository = selfMedicationRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        public async Task HandleAsync(SoftDeleteSelfMedicationCommand command)
        {
            // 1. Get current user
            var userId = _currentUserService.GetCurrentUserId();

            _logger.LogInformation(
                "Attempting Soft Delete SelfMedication. ID: {ID}, PatientID: {PatientID}",
                command.SelfMedicationId,
                userId
            );

            // 2. Get the record
            // ملاحظة: هنا محتاجين نجيب الـ record بأي historyId
            // عشان كده هنعمل method مختلفة شوية في الـ Repository
            var selfMed = await _selfMedicationRepository
                .GetByIdAsync(command.SelfMedicationId, userId, 0); // 0 = any history

            if (selfMed == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Self Medication Not Found. ID: {ID}, PatientID: {PatientID}",
                    command.SelfMedicationId, userId
                );
                throw new KeyNotFoundException("Self medication not found.");
            }

            // 3. Soft delete
            selfMed.IsDeleted = true;
            selfMed.DeletedAt = DateTime.UtcNow;

            await _selfMedicationRepository.SoftDeleteAsync(selfMed);

            _logger.LogInformation(
                "Self Medication Soft Deleted Successfully. ID: {ID}, PatientID: {PatientID}",
                command.SelfMedicationId, userId
            );
        }
    }
}
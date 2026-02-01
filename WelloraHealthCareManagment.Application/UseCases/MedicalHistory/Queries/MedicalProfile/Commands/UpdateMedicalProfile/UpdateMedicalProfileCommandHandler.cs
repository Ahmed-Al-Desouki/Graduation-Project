// Application/UseCases/MedicalProfile/Commands/UpdateMedicalProfile/UpdateMedicalProfileCommandHandler.cs
using HealthCare.Application.Interfaces;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetMedicalProfile;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.Commands.UpdateMedicalProfile
{
    public class UpdateMedicalProfileCommandHandler
    {
        private readonly IMedicalHistoryRepository _medicalHistoryRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UpdateMedicalProfileCommandHandler> _logger;
        private readonly GetMedicalProfileQueryHandler _getMedicalProfileHandler;

        public UpdateMedicalProfileCommandHandler(
            IMedicalHistoryRepository medicalHistoryRepository,
            ICurrentUserService currentUserService,
            ILogger<UpdateMedicalProfileCommandHandler> logger,
            GetMedicalProfileQueryHandler getMedicalProfileHandler)
        {
            _medicalHistoryRepository = medicalHistoryRepository;
            _currentUserService = currentUserService;
            _logger = logger;
            _getMedicalProfileHandler = getMedicalProfileHandler;
        }

        public async Task<MedicalProfileResponse> HandleAsync(UpdateMedicalProfileCommand command)
        {
            var userId = _currentUserService.GetCurrentUserId();

            _logger.LogInformation(
                "Updating medical profile for PatientID: {PatientID}",
                userId);

            // 1. Get existing history or create new
            var historyId = await _medicalHistoryRepository.GetHistoryIdByPatientIdAsync(userId);

            HealthCare_.Models.PatientModels.MedicalHistoryModels.MedicalHistory? history;

            if (historyId.HasValue && historyId.Value > 0)
            {
                // Update existing
                history = await _medicalHistoryRepository.GetByIdWithDetailsAsync(historyId.Value);

                if (history == null)
                    throw new KeyNotFoundException("Medical history not found.");

                // Update fields
                if (command.BloodType != null) history.BloodType = command.BloodType;
                if (command.Allergies != null)
                    history.Allergies = JsonSerializer.Serialize(command.Allergies);
                if (command.ChronicConditions != null)
                    history.ChronicConditions = JsonSerializer.Serialize(command.ChronicConditions);
                if (command.Height.HasValue) history.Height = (double?)command.Height.Value;
                if (command.Weight.HasValue) history.Weight = (double?)command.Weight.Value;
                if (command.DateOfBirth.HasValue) history.DateOfBirth = command.DateOfBirth.Value;
                if (command.Gender != null) history.Gender = command.Gender;
                if (command.CurrentLocation != null) history.CurrentLocation = command.CurrentLocation;
                history.UpdatedAt = DateTime.UtcNow;

                await _medicalHistoryRepository.UpdateAsync(history);
            }
            else
            {
                // Create new
                history = new HealthCare_.Models.PatientModels.MedicalHistoryModels.MedicalHistory
                {
                    PatientID = userId,
                    BloodType = command.BloodType,
                    Allergies = command.Allergies != null
                ? JsonSerializer.Serialize(command.Allergies) : null,
                    ChronicConditions = command.ChronicConditions != null
                ? JsonSerializer.Serialize(command.ChronicConditions) : null,
                    Height = (double?)command.Height,
                    Weight = (double?)command.Weight,
                    DateOfBirth = command.DateOfBirth,
                    Gender = command.Gender,
                    CurrentLocation = command.CurrentLocation,
                    CreatedAt = DateTime.UtcNow
                };

                await _medicalHistoryRepository.AddAsync(history);
            }

            _logger.LogInformation(
                "Medical profile updated successfully for PatientID: {PatientID}",
                userId);

            // 2. Return updated profile
            return await _getMedicalProfileHandler.HandleAsync(new GetMedicalProfileQuery());
        }
    }
}
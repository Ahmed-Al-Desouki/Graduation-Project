using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.PatientDot;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class PatientProfileService : IPatientProfileService
    {
        private readonly IPatientRepository _patientRepository;
        private readonly IUserRepository _userRepository;
        private readonly IMedicalHistoryRepository _medicalHistoryRepository;
        private readonly ILocationLookupService _locationLookupService;
        private readonly INotificationService _notificationService;
        private readonly ILogger<PatientProfileService> _logger;

        public PatientProfileService(
            IPatientRepository patientRepository,
            IUserRepository userRepository,
            IMedicalHistoryRepository medicalHistoryRepository,
            ILocationLookupService locationLookupService,
            INotificationService notificationService,
            ILogger<PatientProfileService> logger)
        {
            _patientRepository = patientRepository;
            _userRepository = userRepository;
            _medicalHistoryRepository = medicalHistoryRepository;
            _locationLookupService = locationLookupService;
            _notificationService = notificationService;
            _logger = logger;
        }

        public async Task<ServiceResult<PatientProfileResponse>> GetProfileAsync(int patientId)
        {
            try
            {
                var patient = await _patientRepository.GetByIdWithUserAsync(patientId);
                if (patient == null)
                {
                    return ServiceResult<PatientProfileResponse>.Failure("Patient not found");
                }

                var response = new PatientProfileResponse
                {
                    PatientId = patient.PatientID,
                    FullName = patient.User.FullName,
                    Email = patient.User.Email ?? string.Empty,
                    PhoneNumber = patient.User.PhoneNumber,
                    Address = patient.User.Address,
                    CurrentLatitude = patient.CurrentLatitude,
                    CurrentLongitude = patient.CurrentLongitude,
                    DateOfBirth = patient.MedicalHistory?.DateOfBirth,
                    Gender = patient.MedicalHistory?.Gender,
                    BloodType = patient.MedicalHistory?.BloodType,
                    Height = patient.MedicalHistory?.Height,
                    Weight = patient.MedicalHistory?.Weight,
                    IsProfileCompleted = patient.IsProfileCompleted,
                    ProfileImageUrl = patient.User.ProfileImagePath?.FileUrl,
                    CreatedAt = patient.CreatedAt,
                    UpdatedAt = patient.UpdatedAt ?? patient.User.UpdatedAt
                };

                return ServiceResult<PatientProfileResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetProfileAsync failed for patient {PatientId}", patientId);
                return ServiceResult<PatientProfileResponse>.Failure("Server error while fetching patient profile");
            }
        }

        public async Task<ServiceResult<PatientProfileResponse>> UpdateBasicInfoAsync(
            int patientId,
            UpdatePatientBasicInfoRequest request)
        {
            return await UpdateOnboardingAsync(patientId, request);
        }

        public async Task<ServiceResult<PatientProfileResponse>> UpdateOnboardingAsync(
            int patientId,
            PatientOnboardingRequest request)
        {
            try
            {
                var patient = await _patientRepository.GetByIdWithUserAsync(patientId);
                if (patient == null)
                {
                    return ServiceResult<PatientProfileResponse>.Failure("Patient not found");
                }

                var user = patient.User;
                var medicalHistory = patient.MedicalHistory;
                var hasChanges = false;
                var latitudeProvided = request.CurrentLatitude.HasValue;
                var longitudeProvided = request.CurrentLongitude.HasValue;

                if (latitudeProvided != longitudeProvided)
                {
                    return ServiceResult<PatientProfileResponse>.Failure("Current latitude and longitude must be provided together");
                }

                if (!string.IsNullOrWhiteSpace(request.FullName))
                {
                    user.FullName = request.FullName;
                    hasChanges = true;
                }

                if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                {
                    user.PhoneNumber = request.PhoneNumber;
                    hasChanges = true;
                }

                if (!latitudeProvided && !string.IsNullOrWhiteSpace(request.Address))
                {
                    user.Address = request.Address;
                    hasChanges = true;
                }

                if (latitudeProvided)
                {
                    var latitude = request.CurrentLatitude!.Value;
                    var longitude = request.CurrentLongitude!.Value;

                    patient.CurrentLatitude = latitude;
                    patient.CurrentLongitude = longitude;
                    user.Address = await _locationLookupService.ResolveAddressAsync(latitude, longitude);
                    hasChanges = true;
                }

                if (latitudeProvided ||
                    !string.IsNullOrWhiteSpace(request.Address) ||
                    request.DateOfBirth.HasValue ||
                    !string.IsNullOrWhiteSpace(request.Gender) ||
                    !string.IsNullOrWhiteSpace(request.BloodType) ||
                    request.Height.HasValue ||
                    request.Weight.HasValue)
                {
                    medicalHistory ??= new MedicalHistory
                    {
                        PatientID = patient.PatientID,
                        CreatedAt = DateTime.UtcNow
                    };

                    if (request.DateOfBirth.HasValue)
                    {
                        medicalHistory.DateOfBirth = request.DateOfBirth.Value;
                    }

                    if (!string.IsNullOrWhiteSpace(request.Gender))
                    {
                        medicalHistory.Gender = request.Gender;
                    }

                    if (!string.IsNullOrWhiteSpace(request.BloodType))
                    {
                        medicalHistory.BloodType = request.BloodType;
                    }

                    if (request.Height.HasValue)
                    {
                        medicalHistory.Height = request.Height.Value;
                    }

                    if (request.Weight.HasValue)
                    {
                        medicalHistory.Weight = request.Weight.Value;
                    }

                    if (!string.IsNullOrWhiteSpace(user.Address))
                    {
                        medicalHistory.CurrentLocation = user.Address;
                    }

                    medicalHistory.UpdatedAt = DateTime.UtcNow;
                    hasChanges = true;
                }

                if (!hasChanges)
                {
                    return ServiceResult<PatientProfileResponse>.Failure("No valid fields were provided for update");
                }

                var wasProfileCompleted = patient.IsProfileCompleted;
                patient.IsProfileCompleted = true;
                user.UpdatedAt = DateTime.UtcNow;
                patient.UpdatedAt = DateTime.UtcNow;

                var userUpdateResult = await _userRepository.UpdateUserAsync(user);
                if (!userUpdateResult.Succeeded)
                {
                    var errors = string.Join(", ", userUpdateResult.Errors.Select(e => e.Description));
                    _logger.LogWarning("UpdateBasicInfoAsync: User update failed for patient {PatientId}. {Errors}", patientId, errors);
                    return ServiceResult<PatientProfileResponse>.Failure(errors);
                }

                if (medicalHistory != null)
                {
                    medicalHistory.CurrentLocation = user.Address;

                    if (patient.MedicalHistory == null)
                    {
                        patient.MedicalHistory = await _medicalHistoryRepository.AddAsync(medicalHistory);
                    }
                    else
                    {
                        await _medicalHistoryRepository.UpdateAsync(medicalHistory);
                    }
                }

                await _patientRepository.UpdateAsync(patient);

                if (!wasProfileCompleted)
                {
                    await _notificationService.NotifyAsync(new NotificationDispatchRequest
                    {
                        UserId = patient.PatientID,
                        Title = "Profile Completed",
                        Message = "Your patient profile has been completed successfully.",
                        Type = NotificationType.PatientProfileCompleted,
                        RelatedEntityType = "Patient",
                        RelatedEntityId = patient.PatientID,
                        Data = new Dictionary<string, string>
                        {
                            ["patientId"] = patient.PatientID.ToString()
                        }
                    });
                }

                return await GetProfileAsync(patientId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UpdateOnboardingAsync failed for patient {PatientId}", patientId);
                return ServiceResult<PatientProfileResponse>.Failure("Server error while updating patient profile");
            }
        }
    }
}

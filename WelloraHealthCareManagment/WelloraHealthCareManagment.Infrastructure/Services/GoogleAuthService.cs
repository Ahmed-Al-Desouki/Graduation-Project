using Google.Apis.Auth;
using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class GoogleAuthService : IGoogleAuthService
    {
        private readonly IUserRepository _userRepository;
        private readonly IPatientRepository _patientRepository;
        private readonly IDoctorRepository _doctorRepository;
        private readonly IMedicalHistoryRepository _medicalHistoryRepository;
        private readonly IUserStatusRepository _userStatusRepository;
        private readonly IAuthCoreService _authCoreService;
        private readonly IFileUploadService _fileUploadService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<GoogleAuthService> _logger;

        public GoogleAuthService(
            IUserRepository userRepository,
            IPatientRepository patientRepository,
            IDoctorRepository doctorRepository,
            IMedicalHistoryRepository medicalHistoryRepository,
            IUserStatusRepository userStatusRepository,
            IAuthCoreService authCoreService,
            IFileUploadService fileUploadService,
            IConfiguration configuration,
            ILogger<GoogleAuthService> logger)
        {
            _userRepository = userRepository;
            _patientRepository = patientRepository;
            _doctorRepository = doctorRepository;
            _medicalHistoryRepository = medicalHistoryRepository;
            _userStatusRepository = userStatusRepository;
            _authCoreService = authCoreService;
            _fileUploadService = fileUploadService;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<(string AccessToken, string RefreshToken, string? Error)> GoogleLoginAsync(
            string idToken,
            string? requestedRole,
            string? deviceInfo,
            string? ipAddress)
        {
            _logger.LogInformation("GoogleLoginAsync: Starting Google login process");

            try
            {
                // 1. Validate Google Token
                var payload = await ValidateGoogleTokenAsync(idToken);
                if (payload == null || string.IsNullOrEmpty(payload.Email))
                {
                    _logger.LogWarning("GoogleLoginAsync: Google token validation failed");
                    return (null!, null!, "Invalid Google token");
                }

                _logger.LogInformation("GoogleLoginAsync: Token validated for email: {Email}", payload.Email);

                // 2. Normalize Role
                var normalizedRole = NormalizeRole(requestedRole);
                _logger.LogInformation("GoogleLoginAsync: Requested role: {Role}", normalizedRole);

                // 3. Get or Create User
                var (user, error) = await GetOrCreateUserAsync(payload, normalizedRole);
                if (user == null || !string.IsNullOrEmpty(error))
                {
                    _logger.LogError("GoogleLoginAsync: Failed to get/create user. Error: {Error}", error);
                    return (null!, null!, error ?? "Failed to create user");
                }

                // 4. Generate Tokens via AuthCoreService
                var result = await _authCoreService.ExternalLoginAsync(user, deviceInfo, ipAddress);

                if (!string.IsNullOrEmpty(result.Error))
                {
                    _logger.LogError("GoogleLoginAsync: Token generation failed. Error: {Error}", result.Error);
                    return (null!, null!, result.Error);
                }

                _logger.LogInformation("GoogleLoginAsync: Login successful for user {UserId}", user.Id);
                return (result.AccessToken, result.RefreshToken, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GoogleLoginAsync: Unexpected error during Google login");
                return (null!, null!, "Server error during Google login");
            }
        }

        public async Task<GooglePayload?> ValidateGoogleTokenAsync(string idToken)
        {
            try
            {
                var audiences = _configuration.GetSection("Auth:GoogleClientIds").Get<List<string>>()
                                ?? new List<string>();

                if (audiences.Count == 0)
                {
                    _logger.LogWarning("ValidateGoogleTokenAsync: No GoogleClientIds configured");
                }

                var settings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = audiences
                };

                var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

                _logger.LogInformation("ValidateGoogleTokenAsync: Token validated successfully for {Email}", payload.Email);

                return new GooglePayload
                {
                    Email = payload.Email,
                    Name = payload.Name,
                    Picture = payload.Picture
                };
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "ValidateGoogleTokenAsync: Google token validation failed");
                return null;
            }
        }

        #region Private Helper Methods

        private string NormalizeRole(string? requestedRole)
        {
            var role = (requestedRole ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(role))
            {
                _logger.LogInformation("NormalizeRole: No role specified, defaulting to Patient");
                return "Patient";
            }

            var allowedRoles = new[] { "Patient", "Doctor" };
            if (!allowedRoles.Any(r => r.Equals(role, StringComparison.OrdinalIgnoreCase)))
            {
                _logger.LogWarning("NormalizeRole: Invalid role '{Role}', defaulting to Patient", role);
                return "Patient";
            }

            return role;
        }

        private async Task<(ApplicationUser? User, string? Error)> GetOrCreateUserAsync(
            GooglePayload payload,
            string requestedRole)
        {
            try
            {
                var email = payload.Email!;
                var user = await _userRepository.GetByEmailAsync(email);

                if (user == null)
                {
                    // Create New User
                    _logger.LogInformation("GetOrCreateUserAsync: Creating new user for {Email}", email);

                    user = new ApplicationUser
                    {
                        UserName = email,
                        Email = email,
                        EmailConfirmed = true,
                        FullName = string.IsNullOrEmpty(payload.Name) ? email : payload.Name,
                        Role = requestedRole,
                        CreatedAt = DateTime.UtcNow
                    };

                    // Create user without password (external login)
                    var createResult = await _userRepository.CreateUserAsync(user, Guid.NewGuid().ToString());
                    if (!createResult.Succeeded)
                    {
                        var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
                        _logger.LogWarning("GetOrCreateUserAsync: User creation failed. Errors: {Errors}", errors);
                        return (null, errors);
                    }

                    // Add Role
                    var addRoleResult = await _userRepository.AddToRoleAsync(user, requestedRole);
                    if (!addRoleResult.Succeeded)
                    {
                        _logger.LogWarning("GetOrCreateUserAsync: AddToRoleAsync failed for user {UserId}", user.Id);
                    }

                    // Create Profile
                    await CreateUserProfileAsync(user, requestedRole);
                    await EnsureUserStatusExistsAsync(user.Id);

                    // Upload Profile Picture
                    if (!string.IsNullOrEmpty(payload.Picture))
                    {
                        await UploadProfilePictureAsync(user, payload.Picture, requestedRole);
                    }

                    _logger.LogInformation("GetOrCreateUserAsync: New user created successfully. UserId: {UserId}", user.Id);
                }
                else
                {
                    // Existing User
                    _logger.LogInformation("GetOrCreateUserAsync: Existing user found: {Email}", email);

                    // Check Role Mismatch
                    if (!string.IsNullOrEmpty(requestedRole) &&
                        !user.Role.Equals(requestedRole, StringComparison.OrdinalIgnoreCase))
                    {
                        _logger.LogWarning("GetOrCreateUserAsync: Role mismatch. User={UserId}, Requested={Req}, Actual={Act}",
                            user.Id, requestedRole, user.Role);

                        return (null, "Role mismatch for existing account. Please use the role upgrade process.");
                    }
                }

                return (user, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetOrCreateUserAsync: Failed");
                return (null, "Server error during user creation");
            }
        }

        private async Task CreateUserProfileAsync(ApplicationUser user, string role)
        {
            try
            {
                if (role.Equals("Patient", StringComparison.OrdinalIgnoreCase))
                {
                    if (!await _patientRepository.PatientExistsByUserIdAsync(user.Id))
                    {
                        _logger.LogInformation("CreateUserProfileAsync: Creating Patient profile for user {UserId}", user.Id);

                        var patient = new Patient
                        {
                            PatientID = user.Id,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };

                        var medicalHistory = new MedicalHistory
                        {
                            PatientID = user.Id,
                            DateOfBirth = null,
                            Gender = "Unknown",
                            CurrentLocation = "Not Specified",
                            BloodType = null,
                            Height = 0,
                            Weight = 0,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };

                        await _patientRepository.CreateAsync(patient);
                        await _medicalHistoryRepository.CreateAsync(medicalHistory);

                        _logger.LogInformation("CreateUserProfileAsync: Patient profile created for user {UserId}", user.Id);
                    }
                }
                else if (role.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
                {
                    if (!await _doctorRepository.DoctorExistsByUserIdAsync(user.Id))
                    {
                        _logger.LogInformation("CreateUserProfileAsync: Creating Doctor profile for user {UserId}", user.Id);

                        var doctor = new Doctor
                        {
                            DoctorId = user.Id,
                            Specialization = "General",
                            YearsOfExperience = 0,
                            //ConsultationFee = 0,
                            IsActive = false,
                            CreatedAt = DateTime.UtcNow
                        };

                        await _doctorRepository.CreateAsync(doctor);

                        _logger.LogInformation("CreateUserProfileAsync: Doctor profile created for user {UserId}", user.Id);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CreateUserProfileAsync: Failed to create profile for user {UserId}", user.Id);
                throw;
            }
        }

        private async Task UploadProfilePictureAsync(ApplicationUser user, string pictureUrl, string role)
        {
            try
            {
                _logger.LogInformation("UploadProfilePictureAsync: Uploading profile picture for user {UserId}", user.Id);

                await _fileUploadService.SaveOrUpdateProfileImageFromUrlAsync(
                    pictureUrl,
                    user.Id,
                    role,
                    "GoogleProfile");

                _logger.LogInformation("UploadProfilePictureAsync: Profile picture uploaded successfully for user {UserId}", user.Id);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "UploadProfilePictureAsync: Failed to upload profile picture for user {UserId}", user.Id);
                // Not throwing - profile picture upload is not critical
            }
        }

        private async Task EnsureUserStatusExistsAsync(int userId)
        {
            if (await _userStatusRepository.ExistsAsync(userId))
                return;

            await _userStatusRepository.CreateAsync(new UserStatus
            {
                UserId = userId,
                IsBlocked = false,
                IsSuspended = false,
                CreatedAt = DateTime.UtcNow
            });
        }

        #endregion
    }
}

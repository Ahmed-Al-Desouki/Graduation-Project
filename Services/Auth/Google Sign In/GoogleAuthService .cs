// File: Services/Auth/GoogleAuthService.cs
using Google.Apis.Auth;
using HealthCare_.Interfaces.Email;
using HealthCare_.Interfaces.IAuth.TokenAndCoreAuth;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
namespace HealthCare_.Services.Auth
{
    public class GoogleAuthService : IGoogleAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IAuthCoreService _authCoreService;
        private readonly IEmailService _emailService;
        private readonly HealthCarePlusContext _context;
        private readonly IConfiguration _configuration;
        private readonly CloudinaryService _cloudinaryService;
        private readonly ILogger<GoogleAuthService> _logger;

        public GoogleAuthService(
            UserManager<ApplicationUser> userManager,
            IAuthCoreService authCoreService,
            IEmailService emailService,
            HealthCarePlusContext context,
            IConfiguration configuration,
            CloudinaryService cloudinaryService,
            ILogger<GoogleAuthService> logger)
        {
            _userManager = userManager;
            _authCoreService = authCoreService;
            _emailService = emailService;
            _context = context;
            _configuration = configuration;
            _cloudinaryService = cloudinaryService;
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
                // === 1. Validate Google Token ===
                var payload = await ValidateGoogleTokenAsync(idToken);
                if (payload == null || string.IsNullOrEmpty(payload.Email))
                {
                    _logger.LogWarning("GoogleLoginAsync: Google token validation failed");
                    return (null!, null!, "Invalid Google token");
                }

                _logger.LogInformation("GoogleLoginAsync: Token validated for email: {Email}", payload.Email);

                // === 2. Normalize Role ===
                var normalizedRole = NormalizeRole(requestedRole);
                _logger.LogInformation("GoogleLoginAsync: Requested role: {Role}", normalizedRole);

                // === 3. Get or Create User ===
                var (user, error) = await GetOrCreateUserAsync(payload, normalizedRole, deviceInfo, ipAddress);
                if (user == null || !string.IsNullOrEmpty(error))
                {
                    _logger.LogError("GoogleLoginAsync: Failed to get/create user. Error: {Error}", error);
                    return (null!, null!, error ?? "Failed to create user");
                }

                // === 4. Generate Tokens via AuthCoreService ===
                var result = await _authCoreService.ExternalLoginAsync(user, deviceInfo, ipAddress, _emailService);

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
            string requestedRole,
            string? deviceInfo,
            string? ipAddress)
        {
            using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                var email = payload.Email!;
                var user = await _userManager.FindByEmailAsync(email);

                if (user == null)
                {
                    // === Create New User ===
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

                    var createResult = await _userManager.CreateAsync(user);
                    if (!createResult.Succeeded)
                    {
                        var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
                        _logger.LogWarning("GetOrCreateUserAsync: User creation failed. Errors: {Errors}", errors);
                        await tx.RollbackAsync();
                        return (null, errors);
                    }

                    // === Add Role ===
                    try
                    {
                        var addRoleResult = await _userManager.AddToRoleAsync(user, requestedRole);
                        if (!addRoleResult.Succeeded)
                        {
                            _logger.LogWarning("GetOrCreateUserAsync: AddToRoleAsync failed for user {UserId}", user.Id);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "GetOrCreateUserAsync: Exception in AddToRoleAsync for user {UserId}", user.Id);
                    }

                    // === Create Profile ===
                    await CreateUserProfileAsync(user, requestedRole);

                    // === Upload Profile Picture ===
                    if (!string.IsNullOrEmpty(payload.Picture))
                    {
                        await UploadProfilePictureAsync(user, payload.Picture, requestedRole);
                    }

                    await _context.SaveChangesAsync();
                    _logger.LogInformation("GetOrCreateUserAsync: New user created successfully. UserId: {UserId}", user.Id);
                }
                else
                {
                    // === Existing User ===
                    _logger.LogInformation("GetOrCreateUserAsync: Existing user found: {Email}", email);

                    // === Check Role Mismatch ===
                    if (!string.IsNullOrEmpty(requestedRole) &&
                        !user.Role.Equals(requestedRole, StringComparison.OrdinalIgnoreCase))
                    {
                        _logger.LogWarning("GetOrCreateUserAsync: Role mismatch. User={UserId}, Requested={Req}, Actual={Act}",
                            user.Id, requestedRole, user.Role);

                        await tx.RollbackAsync();
                        return (null, "Role mismatch for existing account. Please use the role upgrade process.");
                    }
                }

                await tx.CommitAsync();
                _logger.LogInformation("GetOrCreateUserAsync: Transaction committed for user {UserId}", user.Id);
                return (user, null);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                _logger.LogError(ex, "GetOrCreateUserAsync: Transaction failed");
                return (null, "Server error during user creation");
            }
        }

        private async Task CreateUserProfileAsync(ApplicationUser user, string role)
        {
            try
            {
                if (role.Equals("Patient", StringComparison.OrdinalIgnoreCase))
                {
                    if (!await _context.Patients.AnyAsync(p => p.PatientID == user.Id))
                    {
                        _logger.LogInformation("CreateUserProfileAsync: Creating Patient profile for user {UserId}", user.Id);

                        var patient = new HealthCare_.Models.PatientModels.Patient
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
                            Allergies = new List<string>(),
                            ChronicConditions = new List<string>(),
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };

                        patient.MedicalHistory = medicalHistory;
                        _context.Patients.Add(patient);
                        _context.MedicalHistories.Add(medicalHistory);

                        _logger.LogInformation("CreateUserProfileAsync: Patient profile created for user {UserId}", user.Id);
                    }
                }
                else if (role.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
                {
                    if (!await _context.Doctors.AnyAsync(d => d.DoctorID == user.Id))
                    {
                        _logger.LogInformation("CreateUserProfileAsync: Creating Doctor profile for user {UserId}", user.Id);

                        _context.Doctors.Add(new Doctor
                        {
                            DoctorID = user.Id,
                            Specialization = "General",
                            YearsOfExperience = 0,
                            ConsultationFee = 0,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow
                        });

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

                var cloudResult = await _cloudinaryService.UploadUrlToCloudinaryAsync(pictureUrl, "profile_pictures");

                var profileFile = new ExternalFile
                {
                    PatientID = user.Id,
                    FileUrl = cloudResult.Url,
                    PublicId = cloudResult.PublicId,
                    FileType = "image/jpeg",
                    FileSize = 0,
                    UploadedAt = DateTime.UtcNow,
                    UploadedById = user.Id,
                    UploadedByRole = role,
                    CategoryType = "Profile",
                    CategoryValue = "GoogleProfile"
                };

                _context.ExternalFiles.Add(profileFile);
                _logger.LogInformation("UploadProfilePictureAsync: Profile picture uploaded successfully for user {UserId}", user.Id);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "UploadProfilePictureAsync: Failed to upload profile picture for user {UserId}", user.Id);
                // Not throwing - profile picture upload is not critical
            }
        }
    }
}
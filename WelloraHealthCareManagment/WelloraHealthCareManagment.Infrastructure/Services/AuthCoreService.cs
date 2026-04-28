using HealthCare_.Models.AuthModels;
using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.DTOs.AuthModels.Login_register.LogIn;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Search;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class AuthCoreService : IAuthCoreService
    {
        private readonly IUserRepository _userRepository;
        private readonly IPatientRepository _patientRepository;
        private readonly IDoctorRepository _doctorRepository;
        private readonly IMedicalHistoryRepository _medicalHistoryRepository;
        private readonly IUserSessionRepository _sessionRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IRevokedTokenRepository _revokedTokenRepository;
        private readonly ITokenService _tokenService;
        private readonly IFileUploadService _fileUploadService;
        private readonly IAvatarService _avatarService;
        private readonly IMfaService _mfaService;
        private readonly IUserStatusRepository _userStatusRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly IDoctorSearchIndex _searchIndex;
        private readonly INotificationService _notificationService;
        private readonly ILogger<AuthCoreService> _logger;

        public AuthCoreService(
            IUserRepository userRepository,
            IPatientRepository patientRepository,
            IDoctorRepository doctorRepository,
            IMedicalHistoryRepository medicalHistoryRepository,
            IUserSessionRepository sessionRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IRevokedTokenRepository revokedTokenRepository,
            ITokenService tokenService,
            IFileUploadService fileUploadService,
            IAvatarService avatarService,
            IMfaService mfaService,
            IUserStatusRepository userStatusRepository,
            IUnitOfWork unitOfWork,
            IConfiguration configuration,
            IDoctorSearchIndex searchIndex,
            INotificationService notificationService,
            ILogger<AuthCoreService> logger)
        {
            _userRepository = userRepository;
            _patientRepository = patientRepository;
            _doctorRepository = doctorRepository;
            _medicalHistoryRepository = medicalHistoryRepository;
            _sessionRepository = sessionRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _revokedTokenRepository = revokedTokenRepository;
            _tokenService = tokenService;
            _fileUploadService = fileUploadService;
            _avatarService = avatarService;
            _mfaService = mfaService;
            _userStatusRepository = userStatusRepository;
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _searchIndex = searchIndex;
            _notificationService = notificationService;
            _logger = logger;
        }

        #region Register

        //public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
        //{
        //    try
        //    {
        //        // 1. Check if user exists
        //        var existing = await _userRepository.GetByEmailAsync(request.Email);
        //        if (existing != null)
        //        {
        //            return (false, new[] { "Email already registered" });
        //        }

        //        // 2. Create user
        //        var user = new ApplicationUser
        //        {
        //            UserName = request.Email,
        //            Email = request.Email,
        //            FullName = request.FullName,
        //            Role = request.Role ?? "Patient",
        //            CreatedAt = DateTime.UtcNow,
        //            EmailConfirmed = true,
        //            TwoFactorEnabled = true
        //        };

        //        var result = await _userRepository.CreateUserAsync(user, request.Password);
        //        if (!result.Succeeded)
        //        {
        //            return (false, result.Errors.Select(e => e.Description).ToArray());
        //        }

        //        // 3. Add role
        //        await _userRepository.AddToRoleAsync(user, user.Role);

        //        // 4. Create profile (Patient or Doctor)
        //        await CreateUserProfileAsync(user);

        //        // 5. Upload profile image
        //        await UploadProfileImageAsync(user, request.ProfileImageFile);

        //        _logger.LogInformation("User registered successfully: {Email}", request.Email);
        //        return (true, Array.Empty<string>());
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Registration failed for {Email}", request.Email);
        //        return (false, new[] { "Server error during registration" });
        //    }
        //}
        public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
        {
            var existing = await _userRepository.GetByEmailAsync(request.Email);
            if (existing != null)
                return (false, new[] { "Email already registered" });

            // ابدأ transaction
            await using var transaction = await _unitOfWork.BeginTransactionAsync();

            try
            {
                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FullName = request.FullName,
                    //Role = request.Role ?? "Patient",
                    Role = DetermineUserRole(request.Role),
                    CreatedAt = DateTime.UtcNow,
                    EmailConfirmed = true,
                    TwoFactorEnabled = true
                };

                var result = await _userRepository.CreateUserAsync(user, request.Password);
                if (!result.Succeeded)
                    return (false, result.Errors.Select(e => e.Description).ToArray());

                await _userRepository.AddToRoleAsync(user, user.Role);
                await CreateUserProfileAsync(user);  // لو فشل → rollback
                await EnsureUserStatusExistsAsync(user.Id);

                await transaction.CommitAsync();

                // بعد الـ commit اعمل الـ image upload (مش critical)
                await UploadProfileImageAsync(user, request.ProfileImageFile);
                await SendRegistrationNotificationsAsync(user);

                _logger.LogInformation("User registered successfully: {Email}", request.Email);
                return (true, Array.Empty<string>());
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Registration failed for {Email}", request.Email);
                return (false, new[] { "Server error during registration" });
            }
        }

        private async Task CreateUserProfileAsync(ApplicationUser user)
        {
            if (user.Role.Equals("Patient", StringComparison.OrdinalIgnoreCase))
            {
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
            }
            else if (user.Role.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
            {
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
                _searchIndex.AddDoctor(user.FullName, doctor.Specialization);
            }
        }

        private async Task UploadProfileImageAsync(ApplicationUser user, IFormFile? profileImageFile)
        {
            try
            {
                if (profileImageFile != null && profileImageFile.Length > 0)
                {
                    await _fileUploadService.SaveOrUpdateProfileImageAsync(
                        profileImageFile,
                        user.Id,
                        user.Role,
                        "Profile");
                }
                else
                {
                    var avatarResult = await _avatarService.GenerateAndUploadAvatarAsync(user.FullName);
                    await _fileUploadService.SaveOrUpdateProfileImageAsync(
                        avatarResult,
                        user.Id,
                        user.Role,
                        "Profile");
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to upload profile image for user {UserId}", user.Id);
                // Don't throw - profile image is not critical
            }
        }

        #endregion

        #region Login

        public async Task<LoginResponse> LoginAsync(
            LoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            _logger.LogInformation("Login attempt for {Email}", request.Email);

            try
            {
                // 1. Find user
                var user = await _userRepository.GetByEmailAsync(request.Email);
                if (user == null)
                {
                    return LoginResponse.Failed("Email not found");
                }

                // 2. Check password
                if (!await _userRepository.CheckPasswordAsync(user, request.Password))
                {
                    return LoginResponse.Failed("Invalid password");
                }

                var accessRestriction = await ValidateUserAccessAsync(user);
                if (accessRestriction != null)
                    return accessRestriction;

                // 3. Check MFA
                if (string.IsNullOrEmpty(request.OtpCode))
                {
                    // Generate MFA token and send OTP
                    var (mfaToken, _, _) = await _tokenService.GenerateMfaTokenAsync(user);
                    await _mfaService.GenerateAndSendOtpAsync(user);
                    return LoginResponse.MfaRequired(mfaToken);
                }

                // 4. Verify OTP
                var (verified, error) = await _mfaService.VerifyOtpAsync(user.Id, request.OtpCode);
                if (!verified)
                {
                    return LoginResponse.Failed(error);
                }

                // 5. Check Passkey (if applicable)
                if (request.UsePasskey)
                {
                    return LoginResponse.Failed("Passkey authentication required");
                }

                // 6. Generate tokens and create session
                return await CreateLoginSessionAsync(user, deviceInfo, ipAddress);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Login failed for {Email}", request.Email);
                return LoginResponse.Failed("Server error during login");
            }
        }

        #endregion

        #region External Login

        public async Task<(string AccessToken, string RefreshToken, string? Error)> ExternalLoginAsync(
            ApplicationUser user,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            if (user == null)
            {
                _logger.LogWarning("ExternalLoginAsync: User is null");
                return (null!, null!, "User not found");
            }

            _logger.LogInformation("ExternalLoginAsync: Starting for UserId={UserId}", user.Id);

            try
            {
                var accessRestriction = await ValidateUserAccessAsync(user);
                if (accessRestriction != null)
                    return (null!, null!, accessRestriction.Error);

                // Generate tokens and create session
                var result = await CreateLoginSessionAsync(user, deviceInfo, ipAddress);

                if (!string.IsNullOrEmpty(result.Error))
                {
                    return (null!, null!, result.Error);
                }

                return (result.AccessToken!, result.RefreshToken!, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "ExternalLoginAsync failed for UserId={UserId}", user.Id);
                return (null!, null!, "Server error");
            }
        }

        #endregion

        #region Logout

        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            if (request == null || request.UserId <= 0)
            {
                return (false, "Invalid request");
            }

            try
            {
                // 1. Get active session
                var sessions = await _sessionRepository.GetActiveSessionsByUserAsync(request.UserId);
                var session = sessions.FirstOrDefault();

                if (session == null)
                {
                    return (false, "No active session");
                }

                // 2. Revoke session
                session.IsActive = false;
                session.RevokedAt = DateTime.UtcNow;
                await _sessionRepository.UpdateAsync(session);

                // 3. Revoke refresh tokens
                await _refreshTokenRepository.RevokeAllUserTokensAsync(request.UserId);

                // 4. Add Jti to revoked tokens
                if (!string.IsNullOrEmpty(request.Jti))
                {
                    var accessTokenLifetimeMinutes = 1440;
                    if (!int.TryParse(_configuration["Jwt:ExpireMinutes"], out accessTokenLifetimeMinutes) ||
                        accessTokenLifetimeMinutes <= 0)
                    {
                        accessTokenLifetimeMinutes = 1440;
                    }

                    var revokedToken = new RevokedToken
                    {
                        Jti = request.Jti,
                        Expires = DateTime.UtcNow.AddMinutes(accessTokenLifetimeMinutes),
                        RevokedAt = DateTime.UtcNow,
                        UserId = request.UserId
                    };

                    await _revokedTokenRepository.AddAsync(revokedToken);
                }

                _logger.LogInformation("User logged out successfully: {UserId}", request.UserId);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Logout failed for user {UserId}", request.UserId);
                return (false, "Server error during logout");
            }
        }

        #endregion

        #region Session Management (Private Helper)

        private async Task<LoginResponse> CreateLoginSessionAsync(
            ApplicationUser user,
            string? deviceInfo,
            string? ipAddress)
        {
            try
            {
                // 1. Generate tokens
                var (accessToken, jti, _) = await _tokenService.GenerateJwtTokenAsync(user);
                var rawRefresh = _tokenService.GenerateRandomToken();

                // 2. Get max devices limit
                int maxDevices = Convert.ToInt32(_configuration["Auth:MaxActiveDevices"] ?? "3");

                // 3. Get active sessions
                var activeSessions = await _sessionRepository.GetActiveSessionsByUserAsync(user.Id);

                // 4. Revoke oldest session if limit exceeded
                if (activeSessions.Count >= maxDevices)
                {
                    var oldestSession = activeSessions.First();
                    oldestSession.IsActive = false;
                    oldestSession.IsRevoked = true;
                    oldestSession.RevokedAt = DateTime.UtcNow;
                    oldestSession.RevokedByIp = ipAddress;
                    oldestSession.Notes = $"Device limit exceeded (max: {maxDevices})";
                    await _sessionRepository.UpdateAsync(oldestSession);

                    _logger.LogWarning("Revoked oldest session for user {UserId}", user.Id);
                }

                // 5. Revoke same device session if exists
                var existingSameDevice = await _sessionRepository.GetActiveSessionByDeviceAsync(user.Id, deviceInfo);
                if (existingSameDevice != null)
                {
                    existingSameDevice.IsActive = false;
                    existingSameDevice.RevokedAt = DateTime.UtcNow;
                    existingSameDevice.RevokedByIp = ipAddress;
                    existingSameDevice.Notes = "Same device re-login";
                    await _sessionRepository.UpdateAsync(existingSameDevice);
                }

                // 6. Create new session
                var (encryptedToken, tokenSalt) = _tokenService.EncryptAes(rawRefresh);
                var newSession = new UserSession
                {
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    CreatedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "30")),
                    LastActivity = DateTime.UtcNow,
                    IsActive = true,
                    EncryptedToken = encryptedToken,
                    Salt = tokenSalt,
                    Notes = "New login session"
                };

                await _sessionRepository.AddAsync(newSession);

                // 7. Create refresh token
                var refreshEntity = new RefreshToken
                {
                    Token = _tokenService.ComputeHmacSha256Base64(rawRefresh),
                    Expires = newSession.ExpiresAt,
                    CreatedAt = DateTime.UtcNow,
                    JwtId = jti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    UserSessionId = newSession.Id
                };

                await _refreshTokenRepository.AddAsync(refreshEntity);

                _logger.LogInformation("Login session created for user {UserId}", user.Id);

                return LoginResponse.Success(accessToken, rawRefresh);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create login session for user {UserId}", user.Id);
                return LoginResponse.Failed("Server error");
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

        private async Task<LoginResponse?> ValidateUserAccessAsync(ApplicationUser user)
        {
            await EnsureUserStatusExistsAsync(user.Id);

            var userStatus = await _userStatusRepository.GetEffectiveByUserIdAsync(user.Id);
            if (userStatus == null)
                return null;

            if (userStatus.IsBlocked)
            {
                var message = string.IsNullOrWhiteSpace(userStatus.BlockReason)
                    ? "Your account has been blocked. Please contact support."
                    : $"Your account has been blocked. Reason: {userStatus.BlockReason}";

                return LoginResponse.AccessDenied(message, "Blocked");
            }

            if (userStatus.IsSuspended)
            {
                var endDateText = userStatus.SuspensionEndDate.HasValue
                    ? $" until {userStatus.SuspensionEndDate.Value:yyyy-MM-dd HH:mm} UTC"
                    : string.Empty;
                var reasonText = string.IsNullOrWhiteSpace(userStatus.SuspensionReason)
                    ? string.Empty
                    : $" Reason: {userStatus.SuspensionReason}";

                return LoginResponse.AccessDenied(
                    $"Your account is suspended{endDateText}.{reasonText}".Trim(),
                    "Suspended",
                    userStatus.SuspensionEndDate);
            }

            return null;
        }

        private async Task SendRegistrationNotificationsAsync(ApplicationUser user)
        {
            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = user.Id,
                Title = "Welcome to Wellora",
                Message = user.Role.Equals("Doctor", StringComparison.OrdinalIgnoreCase)
                    ? "Your account has been created. Complete your profile and submit your verification documents to start receiving patients."
                    : "Your account has been created successfully. You can now book doctors, manage appointments, and receive updates.",
                Type = NotificationType.Welcome,
                RelatedEntityType = "User",
                RelatedEntityId = user.Id,
                Data = new Dictionary<string, string> { ["role"] = user.Role }
            });

            if (user.Role.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
            {
                await _notificationService.NotifyAdminsAsync(
                    title: "New Doctor Registered",
                    message: $"{user.FullName} has registered as a doctor and may submit verification documents soon.",
                    type: NotificationType.DoctorRegistrationSubmitted,
                    relatedEntityType: "Doctor",
                    relatedEntityId: user.Id,
                    data: new Dictionary<string, string>
                    {
                        ["doctorId"] = user.Id.ToString(),
                        ["doctorName"] = user.FullName
                    });
            }
        }
        private static string DetermineUserRole(string? requestedRole)
        {
            var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "Patient",
                "Doctor"
            };

            return allowed.Contains(requestedRole ?? "")
                ? requestedRole!
                : "Patient";
        }
        #endregion
    }
}

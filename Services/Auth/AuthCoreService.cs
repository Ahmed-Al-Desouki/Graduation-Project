using HealthCare_.Interfaces.IAuth;

using HealthCare_.Models.sharedModels;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Services.Cloud;


namespace HealthCare_.Services.Auth
{
    public class AuthCoreService : IAuthCoreService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly HealthCarePlusContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<AuthCoreService> _logger;
        private readonly CloudinaryService _cloudinary;
        private readonly IEmailService _emailService;
        private readonly ITokenService _tokenService;
        private readonly IMfaService _mfaService;
        private readonly IAvatarService _avatarService;
        private readonly IConfiguration _configuration;

        public AuthCoreService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            HealthCarePlusContext context,
            IHttpContextAccessor httpContextAccessor,
            ILogger<AuthCoreService> logger,
            CloudinaryService cloudinary,
            IEmailService emailService,
            ITokenService tokenService,
            IMfaService mfaService,
            IAvatarService avatarService,
            IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
            _cloudinary = cloudinary;
            _emailService = emailService;
            _tokenService = tokenService;
            _mfaService = mfaService;
            _avatarService = avatarService;
            _configuration = configuration;
        }

        public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
        {
            var existing = await _userManager.FindByEmailAsync(request.Email);
            if (existing != null)
                return (false, new[] { "Email already registered" });

            var user = new ApplicationUser
            {
                UserName = request.Email,
                Email = request.Email,
                FullName = request.FullName,
                Role = request.Role ?? "Patient",
                CreatedAt = DateTime.UtcNow,
                EmailConfirmed = true
            };

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var result = await _userManager.CreateAsync(user, request.Password);
                if (!result.Succeeded)
                    return (false, result.Errors.Select(e => e.Description).ToArray());

                await _userManager.AddToRoleAsync(user, user.Role);

                // رفع الصورة
                ExternalFile? file = null;
                if (request.ProfileImageFile != null && request.ProfileImageFile.Length > 0)
                {
                    var upload = await _cloudinary.UploadFileAsync(request.ProfileImageFile);
                    file = new ExternalFile
                    {
                        FileUrl = upload.Url,
                        PublicId = upload.PublicId,
                        FileType = upload.FileType,
                        FileSize = upload.FileSize,
                        UploadedAt = DateTime.UtcNow,
                        CategoryValue = "Profile"
                    };
                }
                else
                {
                    var (stream, publicId) = await _avatarService.GenerateAndUploadAvatarAsync(request.FullName);
                    file = new ExternalFile
                    {
                        FileUrl = stream.Url,
                        PublicId = publicId,
                        FileType = "image/png",
                        FileSize = stream.FileSize,
                        UploadedAt = DateTime.UtcNow,
                        CategoryValue = "Profile"
                    };
                }

                if (file != null)
                {
                    _context.ExternalFiles.Add(file);
                    await _context.SaveChangesAsync();
                    user.ProfileImageId = file.FileID;
                    await _userManager.UpdateAsync(user);
                }

                // إضافة Patient أو Doctor
                if (user.Role == "Patient")
                {
                    var patient = new Patient
                    {
                        PatientID = user.Id, 
                        DateOfBirth = DateTime.Today.AddYears(-25), 
                        Gender = "Unknown",
                        CreatedAt = DateTime.UtcNow,
                        CurrentLocation = "Not Specified", 
                    };
                    _context.Patients.Add(patient);
                }
                else if (user.Role == "Doctor")
                {
                    var doctor = new Doctor
                    {
                        DoctorID = user.Id, 
                        Specialization = "General",
                        YearsOfExperience = 0,
                        ConsultationFee = 0,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Doctors.Add(doctor);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return (true, Array.Empty<string>());
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Registration failed");
                return (false, new[] { "Server error" });
            }
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
            LoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null,
            IEmailService? emailService = null)
        {
            _logger.LogInformation("LoginAsync called for email: {Email}", request.Email);
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return (null!, null!, "Email not found");

            if (!await _userManager.CheckPasswordAsync(user, request.Password))
                return (null!, null!, "Invalid password");

            if (user.TwoFactorEnabled)
            {
                if (string.IsNullOrEmpty(request.OtpCode))
                {
                    if (emailService != null)
                        await _mfaService.GenerateAndSendOtpAsync(user, emailService);
                    return (null!, null!, "MFA_OTP_SENT");
                }

                var (verified, error) = await _mfaService.VerifyMfaAsync(user.Id, request.OtpCode);
                if (!verified)
                    return (null!, null!, error);
            }

            if (request.UsePasskey)
                return (null!, null!, "Passkey authentication required");

            var (accessToken, jti, _) = await _tokenService.GenerateJwtToken(user);
            var rawRefresh = _tokenService.GenerateRandomToken();
            var refreshHash = _tokenService.ComputeHmacSha256Base64(rawRefresh);

            using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                var sessions = await _context.UserSessions
                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
                    .OrderByDescending(s => s.CreatedAt)
                    .ToListAsync();

                if (sessions.Count >= 3)
                {
                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
                    oldest.RevokeSession("Exceeded session limit");
                    _context.UserSessions.Update(oldest);
                    await _context.SaveChangesAsync();
                }

                var (encryptedToken, tokenSalt) = _tokenService.EncryptAes(rawRefresh);
                var session = new UserSession
                {
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    CreatedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
                    LastActivity = DateTime.UtcNow,
                    IsActive = true,
                    EncryptedToken = encryptedToken,
                    Salt = tokenSalt
                };

                _context.UserSessions.Add(session);
                await _context.SaveChangesAsync();

                var refreshTokenEntity = new RefreshToken
                {
                    Token = refreshHash,
                    Expires = session.ExpiresAt,
                    CreatedAt = DateTime.UtcNow,
                    JwtId = jti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    UserSessionId = session.Id
                };

                _context.RefreshTokens.Add(refreshTokenEntity);
                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                return (accessToken, rawRefresh, string.Empty);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                _logger.LogError(ex, "Login transaction failed");
                return (null!, null!, "Server error");
            }
        }

        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            if (request == null || request.UserId <= 0)
                return (false, "Invalid request");

            var session = await _context.UserSessions
                .FirstOrDefaultAsync(s => s.UserId == request.UserId && s.DeviceInfo == request.DeviceInfo && s.IsActive);

            if (session == null)
                return (false, "No active session");

            session.IsActive = false;
            session.RevokedAt = DateTime.UtcNow;
            _context.UserSessions.Update(session);

            var refreshTokens = await _context.RefreshTokens
                .Where(rt => rt.UserSessionId == session.Id && !rt.IsRevoked)
                .ToListAsync();

            foreach (var rt in refreshTokens)
            {
                rt.IsRevoked = true;
                rt.Revoked = DateTime.UtcNow;
            }

            _context.RefreshTokens.UpdateRange(refreshTokens);
            await _context.SaveChangesAsync();

            return (true, string.Empty);
        }
    }
}
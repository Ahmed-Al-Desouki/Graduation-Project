using HealthCare_.Interfaces.IAuth;
using HealthCare_.Models.PatientModels; 
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

                user.TwoFactorEnabled = true;
                await _userManager.UpdateAsync(user);

                // ================================
                // ❌ تم نقل رفع الصورة من هنا
                // ================================


                // إضافة Patient أو Doctor
                if (user.Role == "Patient")
                {
                    var patient = new HealthCare_.Models.PatientModels.Patient
                    {
                        PatientID = user.Id,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    var medicalHistory = new HealthCare_.Models.PatientModels.MedicalHistory
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

                    patient.MedicalHistory = medicalHistory;

                    _context.Patients.Add(patient);
                    _context.MedicalHistories.Add(medicalHistory);
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

                // =====================================================
                // ✅ تعديل مهم جداً
                // حفظ الـ Patient / Doctor قبل رفع الصورة
                // =====================================================
                await _context.SaveChangesAsync();


                // =====================================================
                // ✅ رفع الصورة بعد ما الـ Patient أو Doctor اتسجل فعلاً
                // =====================================================
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
                    // =====================================================
                    // ✅ ربط الصورة بالمستخدم الصحيح بعد إنشاء السجلات
                    // =====================================================
                    file.PatientID = user.Role == "Patient" ? user.Id : null;
                    file.DoctorID = user.Role == "Doctor" ? user.Id : null;

                    _context.ExternalFiles.Add(file);
                    await _context.SaveChangesAsync();

                    user.ProfileImageId = file.FileID;
                    await _userManager.UpdateAsync(user);
                }

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
            _logger.LogInformation("LoginAsync called for email: {Email} | Device: {Device} | IP: {IP}",
                request.Email, deviceInfo, ipAddress);
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return (null!, null!, "Email not found");
            if (!await _userManager.CheckPasswordAsync(user, request.Password))
                return (null!, null!, "Invalid password");
            //user.TwoFactorEnabled = true;
            //if (user.TwoFactorEnabled)
            {
                if (string.IsNullOrEmpty(request.OtpCode))
                {
                    // === التعديل: توليد mfaToken وإرجاعه مع MFA_PENDING| ===
                    var (mfaToken, mfaJti, _) = await _tokenService.GenerateMfaTokenAsync(user);
                    if (emailService != null)
                        await _mfaService.GenerateAndSendOtpAsync(user, emailService);
                    return (null!, null!, "MFA_PENDING|" + mfaToken);
                    // === نهاية التعديل ===
                }
                var (verified, error) = await _mfaService.VerifyMfaAsync(user.Id, request.OtpCode);
                if (!verified)
                    return (null!, null!, error);
                //}
                if (request.UsePasskey)
                    return (null!, null!, "Passkey authentication required");
                var (accessToken, jti, _) = await _tokenService.GenerateJwtToken(user);
                var rawRefresh = _tokenService.GenerateRandomToken();
                using var tx = await _context.Database.BeginTransactionAsync();
                try
                {
                    // === 1. تحديد الحد الأقصى للأجهزة ===
                    int maxDevices = Convert.ToInt32(_configuration["Auth:MaxActiveDevices"] ?? "3");
                    // === 2. جلب كل السيشنز النشطة لليوزر (من أي جهاز) ===
                    var activeSessions = await _context.UserSessions
                        .Where(s =>
                            s.UserId == user.Id &&
                            s.IsActive &&
                            !s.IsRevoked &&
                            s.ExpiresAt > DateTime.UtcNow)
                        .OrderBy(s => s.CreatedAt) // الأقدم أولاً
                        .ToListAsync();
                    _logger.LogInformation("User has {Count}/{Max} active devices", activeSessions.Count, maxDevices);
                    // === 3. إذا زاد عن الحد → إبطال أقدم سيشن ===
                    if (activeSessions.Count >= maxDevices)
                    {
                        var oldestSession = activeSessions.First();
                        oldestSession.IsActive = false;
                        oldestSession.IsRevoked = true;
                        oldestSession.RevokedAt = DateTime.UtcNow;
                        oldestSession.RevokedByIp = ipAddress;
                        oldestSession.Notes = $"Device limit exceeded (max: {maxDevices}). Revoked on new login.";
                        _context.UserSessions.Update(oldestSession);
                        _logger.LogWarning("Revoked oldest session due to device limit | Id: {Id} | Device: {Device}",
                            oldestSession.Id, oldestSession.DeviceInfo);
                    }
                    // === 4. إبطال أي سيشن قديمة بنفس الجهاز (حتى لو ما زادش الحد) ===
                    var existingSameDevice = await _context.UserSessions
                        .FirstOrDefaultAsync(s =>
                            s.UserId == user.Id &&
                            s.DeviceInfo == deviceInfo &&
                            s.IsActive);
                    if (existingSameDevice != null)
                    {
                        existingSameDevice.IsActive = false;
                        existingSameDevice.RevokedAt = DateTime.UtcNow;
                        existingSameDevice.RevokedByIp = ipAddress;
                        existingSameDevice.Notes = "Same device re-login";
                        _context.UserSessions.Update(existingSameDevice);
                        _logger.LogInformation("Revoked previous session on same device | Id: {Id}", existingSameDevice.Id);
                    }
                    // === 5. إنشاء سيشن جديدة ===
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
                        Notes = "New login with device limit enforcement"
                    };
                    _context.UserSessions.Add(newSession);
                    await _context.SaveChangesAsync();
                    // === 6. إضافة RefreshToken ===
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
                    _context.RefreshTokens.Add(refreshEntity);
                    await _context.SaveChangesAsync();
                    await tx.CommitAsync();
                    _logger.LogInformation("Login successful | UserId: {Id} | SessionId: {SessionId}", user.Id, newSession.Id);
                    return (accessToken, rawRefresh, string.Empty);
                }
                catch (Exception ex)
                {
                    await tx.RollbackAsync();
                    _logger.LogError(ex, "Login transaction failed for user: {Email}", request.Email);
                    return (null!, null!, "Server error");
                }
            }
        }

        // google sign in
        public async Task<(string AccessToken, string RefreshToken, string? Error)> ExternalLoginAsync(
            ApplicationUser user,
            string? deviceInfo = null,
            string? ipAddress = null,
            IEmailService? emailService = null)
        {
            if (user == null)
            {
                _logger.LogWarning("ExternalLoginAsync: User is null");
                return (null!, null!, "User not found");
            }

            _logger.LogInformation("ExternalLoginAsync: Starting login for UserId={UserId}, Device={Device}, IP={IP}",
                user.Id, deviceInfo, ipAddress);

            //user.TwoFactorEnabled = false;
            // === 1. MFA check ===
            //if (user.TwoFactorEnabled)
            //{
            //    _logger.LogInformation("ExternalLoginAsync: MFA enabled for UserId={UserId}", user.Id);
            //    var (mfaToken, mfaJti, _) = await _tokenService.GenerateMfaTokenAsync(user);
            //    if (emailService != null)
            //    {
            //        _logger.LogInformation("ExternalLoginAsync: Sending OTP for MFA to UserId={UserId}", user.Id);
            //        await _mfaService.GenerateAndSendOtpAsync(user, emailService);
            //    }
            //    return (null!, null!, "MFA_PENDING|" + mfaToken);
            //}

            // === 2. Generate access & refresh tokens ===
            var (accessToken, jti, _) = await _tokenService.GenerateJwtToken(user);
            var rawRefresh = _tokenService.GenerateRandomToken();
            _logger.LogInformation("ExternalLoginAsync: Generated JWT and refresh token for UserId={UserId}", user.Id);

            using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                int maxDevices = Convert.ToInt32(_configuration["Auth:MaxActiveDevices"] ?? "3");
                _logger.LogInformation("ExternalLoginAsync: Max active devices allowed: {Max}", maxDevices);

                // === 3. Get active sessions ===
                var activeSessions = await _context.UserSessions
                    .Where(s =>
                        s.UserId == user.Id &&
                        s.IsActive &&
                        !s.IsRevoked &&
                        s.ExpiresAt > DateTime.UtcNow)
                    .OrderBy(s => s.CreatedAt)
                    .ToListAsync();
                _logger.LogInformation("ExternalLoginAsync: User has {Count} active sessions", activeSessions.Count);

                // === 4. Revoke oldest session if limit exceeded ===
                if (activeSessions.Count >= maxDevices)
                {
                    var oldestSession = activeSessions.First();
                    oldestSession.IsActive = false;
                    oldestSession.IsRevoked = true;
                    oldestSession.RevokedAt = DateTime.UtcNow;
                    oldestSession.RevokedByIp = ipAddress;
                    oldestSession.Notes = $"Device limit exceeded (max: {maxDevices}). Revoked on new login.";
                    _context.UserSessions.Update(oldestSession);
                    _logger.LogWarning("ExternalLoginAsync: Revoked oldest session Id={Id}, Device={Device}", oldestSession.Id, oldestSession.DeviceInfo);
                }

                // === 5. Revoke same device session if exists ===
                var existingSameDevice = await _context.UserSessions
                    .FirstOrDefaultAsync(s =>
                        s.UserId == user.Id &&
                        s.DeviceInfo == deviceInfo &&
                        s.IsActive);
                if (existingSameDevice != null)
                {
                    existingSameDevice.IsActive = false;
                    existingSameDevice.RevokedAt = DateTime.UtcNow;
                    existingSameDevice.RevokedByIp = ipAddress;
                    existingSameDevice.Notes = "Same device re-login";
                    _context.UserSessions.Update(existingSameDevice);
                    _logger.LogInformation("ExternalLoginAsync: Revoked previous session on same device, Id={Id}", existingSameDevice.Id);
                }

                // === 6. Create new session ===
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
                    Notes = "New external login session"
                };
                _context.UserSessions.Add(newSession);
                await _context.SaveChangesAsync();
                _logger.LogInformation("ExternalLoginAsync: Created new session Id={Id} for UserId={UserId}", newSession.Id, user.Id);

                // === 7. Create refresh token entity ===
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
                _context.RefreshTokens.Add(refreshEntity);
                await _context.SaveChangesAsync();
                _logger.LogInformation("ExternalLoginAsync: Created refresh token for UserId={UserId}, SessionId={SessionId}", user.Id, newSession.Id);

                await tx.CommitAsync();
                _logger.LogInformation("ExternalLoginAsync: External login completed successfully for UserId={UserId}", user.Id);

                return (accessToken, rawRefresh, string.Empty);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                _logger.LogError(ex, "ExternalLoginAsync: Transaction failed for UserId={UserId}", user.Id);
                return (null!, null!, "Server error");
            }
        }



        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            if (request == null || request.UserId <= 0)
                return (false, "Invalid request");

            var session = await _context.UserSessions
                .FirstOrDefaultAsync(s => s.UserId == request.UserId && s.IsActive);
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

            // ===  Jti إلى RevokedTokens ===
            if (!string.IsNullOrEmpty(request.Jti))
            {
                var existing = await _context.RevokedTokens
                    .AnyAsync(rt => rt.Jti == request.Jti);

                if (!existing)
                {
                    _context.RevokedTokens.Add(new RevokedToken
                    {
                        Jti = request.Jti,
                        Expires = DateTime.UtcNow.AddMinutes(10), // نفس عمر Access Token
                        RevokedAt = DateTime.UtcNow,
                        UserId = request.UserId
                    });
                }
            }

            await _context.SaveChangesAsync();
            return (true, string.Empty);
        }

    }
}
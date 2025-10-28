



namespace HealthCare_.Services.SharedService
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        private readonly HealthCarePlusContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IMemoryCache _cache;
        private readonly IFido2 _fido2;
        private readonly int MaxRefreshTokensPerUser = 3;
        private readonly string _jwtKey;
        private readonly string _refreshHmacKey;
        private readonly string _refreshAesKey;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly ILogger<AuthService> _logger;
        private readonly CloudinaryService _cloudinary;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration,
            HealthCarePlusContext context,
            IHttpContextAccessor httpContextAccessor,
            IMemoryCache cache,
            IFido2 fido2,
            RoleManager<ApplicationRole> roleManager,
            CloudinaryService cloudinary,
            ILogger<AuthService> logger)
        {
            _userManager = userManager;
            _configuration = configuration;
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _cache = cache;
            _fido2 = fido2;
            _jwtKey = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
            _refreshHmacKey = _configuration["Jwt:RefreshTokenHmacKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenHmacKey");
            _refreshAesKey = _configuration["Jwt:RefreshTokenAesKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenAesKey");
            _roleManager = roleManager;
            _cloudinary = cloudinary;
            _logger = logger;

            if (_jwtKey.Length != 44 || _refreshHmacKey.Length != 44 || _refreshAesKey.Length != 44)
                throw new InvalidOperationException("JWT keys must be 44 characters (32 bytes Base64-encoded)");
            _logger.LogInformation("AuthService initialized with keys: JwtKey={JwtKeyLength}, RefreshHmacKey={RefreshHmacKeyLength}, RefreshAesKey={RefreshAesKeyLength}",
                _jwtKey.Length, _refreshHmacKey.Length, _refreshAesKey.Length);
        }

        public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
        {
            _logger.LogInformation("RegisterAsync called for email: {Email}", request.Email);

            var existing = await _userManager.FindByEmailAsync(request.Email);
            if (existing != null)
                return (false, new[] { "Email already registered" });

            var user = new ApplicationUser
            {
                UserName = request.Email,
                Email = request.Email,
                FullName = request.FullName,
                Role = request.Role ?? "Patient",
                Address = "N/A",
                CreatedAt = DateTime.UtcNow,
                TwoFactorEnabled = request.TwoFactorEnabled
            };

            ExternalFile? createdFile = null;
            string? uploadedPublicId = null;

            try
            {
                // 1. رفع الصورة الحقيقية أو توليد افتراضية + رفعها
                if (request.ProfileImageFile != null && request.ProfileImageFile.Length > 0)
                {
                    var result = await _cloudinary.UploadFileAsync(request.ProfileImageFile);
                    createdFile = new ExternalFile
                    {
                        FileUrl = result.Url,
                        PublicId = result.PublicId,
                        FileType = result.FileType,
                        FileSize = result.FileSize,
                        UploadedAt = DateTime.UtcNow,
                        Category = ExternalFileCategory.Profile
                    };
                    uploadedPublicId = result.PublicId;
                }
                else
                {
                    // توليد الصورة الافتراضية + رفعها
                    var (stream, publicId) = await GenerateAndUploadAvatarAsync(request.FullName);
                    uploadedPublicId = publicId;

                    createdFile = new ExternalFile
                    {
                        FileUrl = stream.Url, // مش مهم هنا، هيتحفظ من Cloudinary
                        PublicId = publicId,
                        FileType = "image/png",
                        FileSize = stream.FileSize,
                        UploadedAt = DateTime.UtcNow,
                        Category = ExternalFileCategory.Profile
                    };
                }

                // 2. إنشاء المستخدم
                var identityResult = await _userManager.CreateAsync(user, request.Password);
                if (!identityResult.Succeeded)
                {
                    if (uploadedPublicId != null)
                        await _cloudinary.DeleteFileAsync(uploadedPublicId);
                    return (false, identityResult.Errors.Select(e => e.Description).ToArray());
                }

                // 3. إضافة الـ Role Claim
                await _userManager.AddClaimAsync(user, new Claim(ClaimTypes.Role, user.Role ?? "User"));

                // 4. حفظ الصورة في الـ DB
                if (createdFile != null)
                {
                    _context.ExternalFiles.Add(createdFile);
                    await _context.SaveChangesAsync(); // FileID يُولد

                    user.ProfileImageId = createdFile.FileID;
                    _context.Entry(user).Property(x => x.ProfileImageId).IsModified = true;
                    await _context.SaveChangesAsync();
                }

                _logger.LogInformation("User registered successfully – ID: {Id}, Image: {ImgId}, PublicId: {PublicId}",
                    user.Id, user.ProfileImageId, uploadedPublicId);

                return (true, Array.Empty<string>());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Registration failed for {Email}", request.Email);
                if (uploadedPublicId != null)
                    await _cloudinary.DeleteFileAsync(uploadedPublicId);
                return (false, new[] { "Registration failed due to server error" });
            }
        }
        private static string GetInitials(string fullName)
        {
            var parts = fullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            return parts.Length >= 2
                ? $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}"
                : parts.Length > 0 ? $"{char.ToUpper(parts[0][0])}" : "U";
        }

        private async Task<(CloudinaryUploadResult Result, string PublicId)> GenerateAndUploadAvatarAsync(string fullName)
        {
            var initials = GetInitials(fullName);
            var publicId = $"healthcare_files/avatars/avatar_{initials}_{Guid.NewGuid():N}.png";

            // 1. توليد الصورة
            using var image = new Image<Rgba32>(200, 200);
            image.Mutate(x => x.BackgroundColor(Color.ParseHex("0e76a8")));

            // تحميل خط Arial
            var fontCollection = new FontCollection();
            var fontFamily = fontCollection.Add("C:/Windows/Fonts/arial.ttf"); // تأكد من المسار
            var font = fontFamily.CreateFont(80, FontStyle.Bold);

            var textOptions = new RichTextOptions(font)
            {
                Origin = new PointF(100, 90),
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Center
            };

            image.Mutate(x => x.DrawText(textOptions, initials, Color.White));

            // 2. تحويل إلى Stream
            using var ms = new MemoryStream();
            await image.SaveAsPngAsync(ms);
            ms.Position = 0;

            // 3. رفع على Cloudinary باستخدام UploadFileAsync
            var file = new FormFile(ms, 0, ms.Length, "avatar", $"{initials}.png")
            {
                Headers = new HeaderDictionary(),
                ContentType = "image/png"
            };

            var uploadResult = await _cloudinary.UploadFileAsync(file);

            // تأكد إن UploadFileAsync بيرجع CloudinaryUploadResult
            return (
                uploadResult,
                uploadResult.PublicId
            );
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
            LoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            _logger.LogInformation("LoginAsync called for email: {Email}", request.Email);
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
            {
                _logger.LogWarning("Login failed: Email {Email} not found", request.Email);
                return (null!, null!, "Email not found");
            }

            if (!await _userManager.CheckPasswordAsync(user, request.Password))
            {
                _logger.LogWarning("Login failed: Invalid password for email {Email}", request.Email);
                return (null!, null!, "Invalid password");
            }

            if (await _userManager.GetTwoFactorEnabledAsync(user))
            {
                if (string.IsNullOrEmpty(request.OtpCode))
                {
                    _logger.LogWarning("Login failed: MFA required for email {Email}", request.Email);
                    return (null!, null!, "MFA required: OTP code needed");
                }

                if (!await _userManager.VerifyTwoFactorTokenAsync(user, "Authenticator", request.OtpCode))
                {
                    _logger.LogWarning("Login failed: Invalid OTP code for email {Email}", request.Email);
                    return (null!, null!, "Invalid OTP code");
                }
            }

            if (request.UsePasskey)
            {
                _logger.LogWarning("Login failed: Passkey authentication required for email {Email}", request.Email);
                return (null!, null!, "Passkey authentication required");
            }

            var (accessToken, jti, expiresAt) = await GenerateJwtToken(user);
            var rawRefresh = GenerateRandomToken();
            var refreshHash = ComputeHmacSha256Base64(rawRefresh);

            _logger.LogDebug("Generating session for user {UserId} with jti: {Jti}", user.Id, jti);
            using (var tx = await _context.Database.BeginTransactionAsync())
            {
                var sessions = await _context.UserSessions
                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
                    .OrderByDescending(s => s.CreatedAt)
                    .ToListAsync();

                if (sessions.Count >= MaxRefreshTokensPerUser)
                {
                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
                    oldest.RevokeSession("Exceeded session limit");
                    _context.UserSessions.Update(oldest);
                    await _context.SaveChangesAsync();
                    _logger.LogInformation("Revoked oldest session for user {UserId} due to limit", user.Id);
                }

                var (encryptedToken, tokenSalt) = EncryptAes(rawRefresh);
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
                _logger.LogInformation("Session and refresh token created for user {UserId}", user.Id);
            }


            var (encryptedForClient, _) = EncryptAes(rawRefresh); // ده للـ UserSession بس
            _logger.LogInformation("Login successful for user {UserId} with access token length: {TokenLength}", user.Id, accessToken.Length);
            return (accessToken, rawRefresh, string.Empty); // بعت rawRefresh للـ client بدل encrypted

            //var (encryptedForClient, _) = EncryptAes(rawRefresh);
            //return (accessToken, encryptedForClient, string.Empty);
        }

        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            _logger.LogInformation("LogoutAsync called for userId: {UserId}", request?.UserId);
            try
            {
                if (request == null || request.UserId <= 0)
                {
                    _logger.LogWarning("Logout failed: Invalid logout request for userId: {UserId}", request?.UserId);
                    return (false, "Invalid logout request");
                }

                var session = await _context.UserSessions
                    .Where(s => s.UserId == request.UserId && s.DeviceInfo == request.DeviceInfo && s.IsActive)
                    .OrderByDescending(s => s.LastActivity)
                    .FirstOrDefaultAsync();

                if (session == null)
                {
                    _logger.LogWarning("Logout failed: No active session found for userId: {UserId}", request.UserId);
                    return (false, "No active session found for this user/device");
                }

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
                _logger.LogInformation("Logout successful for userId: {UserId}", request.UserId);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Logout failed for userId: {UserId}", request?.UserId);
                return (false, $"Logout failed: {ex.Message}");
            }
        }

        public async Task<int?> GetRoleIdFromDbAsync(string roleName)
        {
            _logger.LogInformation("GetRoleIdFromDbAsync called for roleName: {RoleName}", roleName);
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role == null)
                _logger.LogWarning("Role not found: {RoleName}", roleName);
            return role?.Id;
        }

        public async Task<(bool Succeeded, int? RoleId, string Error)> CreateRoleAsync(string roleName, string description)
        {
            _logger.LogInformation("CreateRoleAsync called for roleName: {RoleName}", roleName);
            var role = new ApplicationRole
            {
                Name = roleName,
                NormalizedName = roleName.ToUpper(),
                Description = description,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _roleManager.CreateAsync(role);
            if (result.Succeeded)
            {
                _logger.LogInformation("Role created successfully: {RoleName} with Id: {RoleId}", roleName, role.Id);
                return (true, role.Id, string.Empty);
            }

            _logger.LogError("Role creation failed for {RoleName}: {Errors}", roleName, string.Join(", ", result.Errors.Select(e => e.Description)));
            return (false, null, string.Join(", ", result.Errors.Select(e => e.Description)));
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
                            RefreshRequest request,
                            string? deviceInfo = null,
                            string? ipAddress = null)
        {
            _logger.LogInformation("RefreshTokenAsync called");

            if (request == null || string.IsNullOrEmpty(request.AccessToken) || string.IsNullOrEmpty(request.RefreshToken))
            {
                return (string.Empty, string.Empty, "Access token and refresh token are required.");
            }

            // تنظيف الـ accessToken
            var cleanedAccessToken = request.AccessToken.Trim().Replace("Bearer ", "");

            // التحقق من JWT
            if (cleanedAccessToken.Split('.').Length != 3)
            {
                _logger.LogError("Invalid JWT format");
                return (string.Empty, string.Empty, "Invalid access token format");
            }

            // Validate access token
            var tokenHandler = new JwtSecurityTokenHandler();
            ClaimsPrincipal principal;
            SecurityToken validatedToken;

            try
            {
                principal = tokenHandler.ValidateToken(cleanedAccessToken, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidAudience = _configuration["Jwt:Audience"],
                    ValidateLifetime = false
                }, out validatedToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Invalid access token");
                return (string.Empty, string.Empty, $"Invalid access token: {ex.Message}");
            }

            var jwtToken = validatedToken as JwtSecurityToken;
            var jti = jwtToken?.Id;
            var userIdClaim = principal.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
            {
                return (string.Empty, string.Empty, "Invalid token claims");
            }

            // حساب Hash من الـ raw refreshToken اللي بعته الـ client
            var providedHash = ComputeHmacSha256Base64(request.RefreshToken);
            _logger.LogDebug("Provided hash: {Hash}", providedHash);

            using (var tx = await _context.Database.BeginTransactionAsync())
            {
                var stored = await _context.RefreshTokens
                    .Include(rt => rt.UserSession)
                    .Where(rt => rt.Token == providedHash && rt.UserId == userId)
                    .FirstOrDefaultAsync();

                if (stored == null || stored.IsUsed || stored.IsRevoked)
                {
                    _logger.LogWarning("Invalid refresh token for userId: {UserId}", userId);
                    return (string.Empty, string.Empty, "Invalid refresh token");
                }

                if (stored.Expires < DateTime.UtcNow)
                {
                    return (string.Empty, string.Empty, "Refresh token expired");
                }

                if (stored.JwtId != jti)
                {
                    return (string.Empty, string.Empty, "Refresh token does not match access token");
                }

                // revoke القديم
                stored.IsUsed = true;
                stored.IsRevoked = true;
                stored.Revoked = DateTime.UtcNow;
                _context.RefreshTokens.Update(stored);

                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                {
                    await tx.RollbackAsync();
                    return (string.Empty, string.Empty, "User not found");
                }

                var (newAccessToken, newJti, _) = await GenerateJwtToken(user);
                var newRefreshRaw = GenerateRandomToken();
                var newRefreshHash = ComputeHmacSha256Base64(newRefreshRaw);

                var newRefreshEntity = new RefreshToken
                {
                    Token = newRefreshHash,
                    Expires = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
                    CreatedAt = DateTime.UtcNow,
                    JwtId = newJti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo ?? stored.DeviceInfo,
                    IpAddress = ipAddress ?? stored.IpAddress,
                    UserSessionId = stored.UserSessionId
                };

                _context.RefreshTokens.Add(newRefreshEntity);

                // تحديث Session (اختياري)
                if (stored.UserSessionId.HasValue)
                {
                    var sessionUpdate = await _context.UserSessions.FindAsync(stored.UserSessionId.Value);
                    if (sessionUpdate != null)
                    {
                        sessionUpdate.LastActivity = DateTime.UtcNow;
                        _context.UserSessions.Update(sessionUpdate);
                    }
                }

                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                _logger.LogInformation("Refresh succeeded for userId: {UserId}", userId);
                return (newAccessToken, newRefreshRaw, string.Empty); // بعت rawRefresh جديد
            }
        }


        public async Task<(bool Succeeded, string QrCodeUrl, string[] RecoveryCodes, string Error)> EnableMfaAsync(int userId)
        {
            _logger.LogInformation("EnableMfaAsync called for userId: {UserId}", userId);
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null)
            {
                return (false, string.Empty, Array.Empty<string>(), "User not found");
            }

            if (await _userManager.GetTwoFactorEnabledAsync(user))
            {
                return (false, string.Empty, Array.Empty<string>(), "MFA already enabled");
            }

            var authenticatorKey = await _userManager.GetAuthenticatorKeyAsync(user);
            if (string.IsNullOrEmpty(authenticatorKey))
            {
                await _userManager.ResetAuthenticatorKeyAsync(user);
                authenticatorKey = await _userManager.GetAuthenticatorKeyAsync(user);
                _logger.LogDebug("Authenticator key reset for userId: {UserId}, new key: {Key}", userId, authenticatorKey);
            }


            // رابط الـ otpauth الأصلي لتطبيق Google Authenticator
            var otpauthUri = $"otpauth://totp/{Uri.EscapeDataString(user.Email)}?secret={authenticatorKey}&issuer=HealthCareApp&period=60";

            // رابط يمكن فتحه مباشرة من Flutter، 
            // بحيث عند الضغط عليه من الهاتف يحاول فتح Google Authenticator،
            // أو يفتح Google Play / App Store في حال عدم وجود التطبيق.
            var qrCodeUrl = $"intent://totp/{Uri.EscapeDataString(user.Email)}?secret={authenticatorKey}&issuer=HealthCareApp&period=60#Intent;scheme=otpauth;package=com.google.android.apps.authenticator2;end";

            var recoveryCodes = await _userManager.GenerateNewTwoFactorRecoveryCodesAsync(user, 10);

            user.TwoFactorEnabled = true;
            user.AuthenticatorKey = authenticatorKey;
            user.RecoveryCodes = string.Join(",", recoveryCodes ?? Array.Empty<string>());

            var updateResult = await _userManager.UpdateAsync(user);
            if (!updateResult.Succeeded)
            {
                _logger.LogError("Failed to update user for MFA: {Errors}", string.Join(", ", updateResult.Errors.Select(e => e.Description)));
                return (false, string.Empty, Array.Empty<string>(), "Failed to enable MFA");
            }

            // تحقق من الـ update
            var updatedUser = await _userManager.FindByIdAsync(userId.ToString());
            var isTwoFactorEnabled = await _userManager.GetTwoFactorEnabledAsync(updatedUser);
            _logger.LogDebug("After update: TwoFactorEnabled = {Enabled}, AuthenticatorKey = {Key}", isTwoFactorEnabled, updatedUser.AuthenticatorKey);

            if (!isTwoFactorEnabled)
            {
                _logger.LogError("TwoFactorEnabled still false after update for userId: {UserId}", userId);
                return (false, string.Empty, Array.Empty<string>(), "Failed to enable MFA");
            }

            _logger.LogInformation("MFA enabled successfully for userId: {UserId}", userId);
            return (true, qrCodeUrl, recoveryCodes?.ToArray() ?? Array.Empty<string>(), string.Empty);
        }


        public async Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode)
        {
            _logger.LogInformation("VerifyMfaAsync called for userId: {UserId}, OTP: {OtpCode}", userId, otpCode);
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null)
            {
                _logger.LogWarning("VerifyMfaAsync failed: User not found for userId: {UserId}", userId);
                return (false, "User not found");
            }

            var enabled = await _userManager.GetTwoFactorEnabledAsync(user);
            _logger.LogDebug("MFA enabled for userId {UserId}: {Enabled}", userId, enabled);

            if (!enabled)
            {
                _logger.LogWarning("VerifyMfaAsync failed: MFA not enabled for userId: {UserId}", userId);
                return (false, "MFA not enabled");
            }

            var recoveryCodes = user.RecoveryCodes?.Split(",");
            _logger.LogDebug("Recovery codes for user {UserId}: {Codes}", userId, recoveryCodes != null ? string.Join(", ", recoveryCodes) : "None");
            _logger.LogDebug("Attempting to verify OTP code: {OtpCode}", otpCode);

            // التحقق اليدوي من RecoveryCodes
            if (recoveryCodes != null && recoveryCodes.Contains(otpCode, StringComparer.OrdinalIgnoreCase))
            {
                _logger.LogInformation("Manual recovery code verification successful for code: {OtpCode}", otpCode);
                // إزالة الكود المستخدم
                user.RecoveryCodes = string.Join(",", recoveryCodes.Where(c => !c.Equals(otpCode, StringComparison.OrdinalIgnoreCase)));
                var updateResult = await _userManager.UpdateAsync(user);
                if (!updateResult.Succeeded)
                {
                    _logger.LogError("Failed to update recovery codes for user {UserId}: {Errors}", userId, string.Join(", ", updateResult.Errors.Select(e => e.Description)));
                    return (false, "Failed to update recovery codes");
                }
                await _userManager.AddClaimAsync(user, new Claim("amr", "mfa"));
                _logger.LogInformation("MFA verified successfully for userId: {UserId}", userId);
                return (true, string.Empty);
            }

            // التحقق باستخدام Authenticator لرموز OTP
            var verified = await _userManager.VerifyTwoFactorTokenAsync(user, "Authenticator", otpCode);
            _logger.LogDebug("OTP verification result for userId {UserId}, OTP {OtpCode}: {Verified}", userId, otpCode, verified);

            if (verified)
            {
                await _userManager.AddClaimAsync(user, new Claim("amr", "mfa"));
                _logger.LogInformation("MFA verified successfully for userId: {UserId}", userId);
                return (true, string.Empty);
            }

            _logger.LogWarning("VerifyMfaAsync failed: Invalid OTP code for userId: {UserId}, Provided OTP: {OtpCode}", userId, otpCode);
            return (false, "Invalid OTP code");
        }

        public async Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, string credentialId, string publicKey)
        {
            _logger.LogInformation("RegisterPasskeyAsync called for userId: {UserId}", userId);
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null)
            {
                _logger.LogWarning("RegisterPasskeyAsync failed: User not found for userId: {UserId}", userId);
                return (false, "User not found");
            }

            user.PasskeyCredentialId = credentialId;
            user.PasskeyPublicKey = publicKey;
            await _userManager.UpdateAsync(user);
            _logger.LogInformation("Passkey registered successfully for userId: {UserId}", userId);
            return (true, string.Empty);
        }

        public async Task<string> GeneratePasskeyChallengeAsync(string userId)
        {
            _logger.LogInformation("GeneratePasskeyChallengeAsync called for userId: {UserId}", userId);
            var challenge = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(challenge);
            }
            var challengeBase64 = Convert.ToBase64String(challenge);

            // Store challenge in cache with 5-minute expiration
            _cache.Set($"passkey_challenge_{userId}", challenge, new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
            });

            _logger.LogDebug("Generated challenge for userId: {UserId}", userId);
            return await Task.FromResult(challengeBase64);
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(
            PasskeyLoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            _logger.LogInformation("LoginWithPasskeyAsync called for credentialId: {CredentialId}", request?.CredentialId);
            if (request == null || string.IsNullOrEmpty(request.CredentialId) || string.IsNullOrEmpty(request.AuthenticatorData) ||
                string.IsNullOrEmpty(request.ClientDataJson) || string.IsNullOrEmpty(request.Signature))
            {
                _logger.LogWarning("LoginWithPasskeyAsync failed: Invalid request or missing required fields");
                return (null!, null!, "Invalid request or missing required fields");
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.PasskeyCredentialId == request.CredentialId);
            if (user == null)
            {
                _logger.LogWarning("LoginWithPasskeyAsync failed: No user found with credentialId: {CredentialId}", request.CredentialId);
                return (null!, null!, "No user found with this passkey");
            }

            // Retrieve challenge from cache
            if (!_cache.TryGetValue($"passkey_challenge_{user.Id}", out byte[]? challenge) || challenge == null)
            {
                _logger.LogWarning("LoginWithPasskeyAsync failed: No valid challenge found for userId: {UserId}", user.Id);
                return (null!, null!, "No valid challenge found");
            }

            if (!await VerifyPasskeySignature(request, user.PasskeyPublicKey, challenge, user.Id.ToString()))
            {
                _logger.LogWarning("LoginWithPasskeyAsync failed: Invalid passkey signature for userId: {UserId}", user.Id);
                return (null!, null!, "Invalid passkey signature");
            }

            // Clear challenge after use
            _cache.Remove($"passkey_challenge_{user.Id}");

            var (accessToken, jti, expiresAt) = await GenerateJwtToken(user);
            var rawRefresh = GenerateRandomToken();
            var refreshHash = ComputeHmacSha256Base64(rawRefresh);

            _logger.LogDebug("Generating session for user {UserId} with jti: {Jti}", user.Id, jti);
            using (var tx = await _context.Database.BeginTransactionAsync())
            {
                var sessions = await _context.UserSessions
                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
                    .OrderByDescending(s => s.CreatedAt)
                    .ToListAsync();

                if (sessions.Count >= MaxRefreshTokensPerUser)
                {
                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
                    oldest.RevokeSession("Exceeded session limit");
                    _context.UserSessions.Update(oldest);
                    await _context.SaveChangesAsync();
                    _logger.LogInformation("Revoked oldest session for user {UserId} due to limit", user.Id);
                }

                var (encryptedToken, encSalt) = EncryptAes(rawRefresh);
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
                    Salt = encSalt
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
                _logger.LogInformation("Session and refresh token created for user {UserId}", user.Id);
            }

            var (encryptedForClient, finalSalt) = EncryptAes(rawRefresh);
            _logger.LogInformation("LoginWithPasskeyAsync successful for user {UserId} with access token length: {TokenLength}", user.Id, accessToken.Length);
            return (accessToken, encryptedForClient, string.Empty);
        }

        private async Task<(string Token, string Jti, DateTime Expires)> GenerateJwtToken(ApplicationUser user)
        {
            _logger.LogInformation("GenerateJwtToken called for userId: {UserId}", user.Id);
            var jwtSection = _configuration.GetSection("Jwt");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var jti = Guid.NewGuid().ToString();
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email ?? string.Empty),
                new Claim("UserID", user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, jti),
                new Claim("amr", user.TwoFactorEnabled ? "mfa" : user.PasskeyCredentialId != null ? "passkey" : "pwd")
            };

            var roles = await _userManager.GetRolesAsync(user);
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
                _logger.LogDebug("Added role claim: {Role} for userId: {UserId}", role, user.Id);
            }

            var expiryMinutes = Convert.ToDouble(jwtSection["ExpireMinutes"] ?? "15");
            var payload = new JwtPayload(
                issuer: jwtSection["Issuer"],
                audience: jwtSection["Audience"],
                claims: claims,
                notBefore: DateTime.UtcNow,
                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
                issuedAt: DateTime.UtcNow
            );
            var header = new JwtHeader(creds);
            var token = new JwtSecurityToken(header, payload);
            var expires = token.ValidTo;
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            _logger.LogInformation("Generated token for user {UserId}: {Token}", user.Id, tokenString.Substring(0, 10) + "...");
            return (tokenString, jti, expires);
        }

        private string GenerateRandomToken()
        {
            _logger.LogDebug("Generating random token");
            var randomBytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            return Convert.ToBase64String(randomBytes);
        }

        private string ComputeHmacSha256Base64(string input)
        {
            _logger.LogDebug("Computing HMAC-SHA256 for input length: {InputLength}", input?.Length);
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_refreshHmacKey));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToBase64String(hash);
        }

        private (string EncryptedText, string Salt) EncryptAes(string plainText)
        {
            _logger.LogDebug("Encrypting AES for plain text length: {PlainTextLength}", plainText?.Length);
            if (string.IsNullOrEmpty(plainText)) return (string.Empty, string.Empty);

            var saltBytes = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }

            using var derivedKey = new Rfc2898DeriveBytes(_refreshAesKey, saltBytes, 10000, HashAlgorithmName.SHA256);
            using var aes = Aes.Create();
            aes.Key = derivedKey.GetBytes(32);
            aes.GenerateIV();
            using var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
            var plainBytes = Encoding.UTF8.GetBytes(plainText);
            var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
            var combined = new byte[saltBytes.Length + aes.IV.Length + cipherBytes.Length];
            Array.Copy(saltBytes, 0, combined, 0, saltBytes.Length);
            Array.Copy(aes.IV, 0, combined, saltBytes.Length, aes.IV.Length);
            Array.Copy(cipherBytes, 0, combined, saltBytes.Length + aes.IV.Length, cipherBytes.Length);
            return (Convert.ToBase64String(combined), Convert.ToBase64String(saltBytes));
        }

        // Example DecryptAes method with enhanced error handling
        private string DecryptAes(string encryptedToken, string salt)
        {
            try
            {
                if (string.IsNullOrEmpty(encryptedToken) || string.IsNullOrEmpty(salt))
                {
                    _logger.LogWarning("DecryptAes: Encrypted token or salt is null or empty");
                    return string.Empty;
                }

                byte[] encryptedBytes = Convert.FromBase64String(encryptedToken);
                byte[] saltBytes = Convert.FromBase64String(salt);
                byte[] keyBytes = Convert.FromBase64String(_configuration["Jwt:RefreshTokenAesKey"]);

                using (var aes = Aes.Create())
                {
                    aes.Key = keyBytes;
                    aes.IV = saltBytes.Take(16).ToArray(); // Ensure IV is 16 bytes
                    aes.Padding = PaddingMode.PKCS7;
                    aes.Mode = CipherMode.CBC;

                    using (var decryptor = aes.CreateDecryptor(aes.Key, aes.IV))
                    using (var ms = new MemoryStream(encryptedBytes))
                    using (var cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
                    using (var reader = new StreamReader(cs))
                    {
                        return reader.ReadToEnd();
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning("DecryptAes failed for token. Last error: {Error}", ex.Message);
                return string.Empty;
            }
        }

        private async Task<bool> VerifyPasskeySignature(
                PasskeyLoginRequest request,
                string? publicKeyBase64,
                byte[] challenge,
                string userId)
        {
            _logger.LogDebug("Verifying passkey signature for credentialId: {CredentialId}", request?.CredentialId);

            if (string.IsNullOrEmpty(publicKeyBase64) || request == null)
            {
                _logger.LogWarning("Public key or request is missing");
                return false;
            }

            try
            {
                // استرجاع المستخدم من قاعدة البيانات
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Id.ToString() == userId);
                if (user == null || string.IsNullOrEmpty(user.PasskeyCredentialId))
                {
                    _logger.LogWarning("User or credential not found for userId: {UserId}", userId);
                    return false;
                }

                // تحويل المفاتيح من Base64 إلى Bytes
                var credentialIdBytes = Convert.FromBase64String(request.CredentialId);
                var storedPublicKeyBytes = Convert.FromBase64String(publicKeyBase64);

                // إعداد تكوين FIDO2
                var fidoConfig = new Fido2Configuration
                {
                    ServerDomain = _configuration["WebAuthn:RpId"] ?? "localhost",
                    ServerName = "HealthCare App",
                    Origins = new HashSet<string>
                    {
                        _configuration["WebAuthn:Origin"] ?? "https://localhost:7092"
                    }
                };

                // إنشاء Assertion Options
                var credentialDescriptor = new PublicKeyCredentialDescriptor(
                    PublicKeyCredentialType.PublicKey,
                    credentialIdBytes);

                var assertionOptions = AssertionOptions.Create(
                    fidoConfig,
                    challenge,
                    new[] { credentialDescriptor },
                    UserVerificationRequirement.Preferred,
                    null);

                // حفظ الخيارات مؤقتًا في الكاش
                var optionsJson = assertionOptions.ToJson();
                _cache.Set($"assertion_options_{userId}", optionsJson, TimeSpan.FromMinutes(5));
                var options = AssertionOptions.FromJson(optionsJson);

                // دالة التحقق من ملكية الـ Credential
                IsUserHandleOwnerOfCredentialIdAsync callback = async (args, cancellationToken) =>
                {
                    var storedCreds = await _context.Users
                        .Where(u => u.PasskeyCredentialId != null)
                        .Select(u => u.PasskeyCredentialId)
                        .ToListAsync(cancellationToken);

                    return storedCreds.Any(credId =>
                        Convert.FromBase64String(credId!).SequenceEqual(args.CredentialId));
                };

                // تجهيز بيانات الاستجابة (Response)
                var assertionResponse = new AuthenticatorAssertionRawResponse
                {
                    Type = PublicKeyCredentialType.PublicKey,
                    RawId = credentialIdBytes,
                    Response = new AuthenticatorAssertionRawResponse.AssertionResponse
                    {
                        AuthenticatorData = Convert.FromBase64String(request.AuthenticatorData ?? string.Empty),
                        ClientDataJson = Encoding.UTF8.GetBytes(request.ClientDataJson ?? string.Empty),
                        Signature = Convert.FromBase64String(request.Signature ?? string.Empty),
                        UserHandle = Encoding.UTF8.GetBytes(userId)
                    },
                    Extensions = new AuthenticationExtensionsClientOutputs()
                };

                // إعداد معاملات التحقق
                var makeAssertionParams = new MakeAssertionParams
                {
                    AssertionResponse = assertionResponse,
                    OriginalOptions = options,
                    StoredPublicKey = storedPublicKeyBytes,
                    StoredSignatureCounter = 0, // يمكنك التحديث لاحقًا من قاعدة البيانات
                    IsUserHandleOwnerOfCredentialIdCallback = callback
                };

                // تنفيذ التحقق
                var result = await _fido2.MakeAssertionAsync(makeAssertionParams, CancellationToken.None);

                // إذا وصلنا هنا بدون استثناء → التحقق ناجح
                _logger.LogInformation("Passkey verification succeeded for credentialId: {CredentialId}", request.CredentialId);
                _cache.Remove($"assertion_options_{userId}");

                // يمكنك استخدام result.SignCount و result.IsBackedUp لو أردت
                _logger.LogDebug("SignCount: {SignCount}, IsBackedUp: {IsBackedUp}", result.SignCount, result.IsBackedUp);

                return true;
            }
            catch (Fido2VerificationException ex)
            {
                // استثناء تحقق من FIDO2 (فشل التحقق)
                _logger.LogWarning("Passkey verification failed (FIDO2): {Error}", ex.Message);
                return false;
            }
            catch (Exception ex)
            {
                // أي خطأ آخر (مثل JSON أو قاعدة البيانات)
                _logger.LogError(ex, "Passkey verification error for credentialId: {CredentialId}", request?.CredentialId);
                return false;
            }
        }

        // Helper class to match expected credential structure
        private class StoredCredential
        {
            public byte[] Id { get; set; } = null!;
            public byte[] PublicKey { get; set; } = null!;
            public uint SignCount { get; set; }
        }
    }
}

//using HealthCare_.Interfaces.IAuth;
//using HealthCare_.Models.DTOs.Email;
//using Microsoft.AspNetCore.Http.Headers;
//using Microsoft.AspNetCore.Identity;
//using Microsoft.AspNetCore.WebUtilities;
//using Microsoft.EntityFrameworkCore;
//using Microsoft.IdentityModel.Tokens;
//using Microsoft.Net.Http.Headers;
//using SixLabors.Fonts;
//using SixLabors.ImageSharp;
//using SixLabors.ImageSharp.Drawing.Processing;
//using SixLabors.ImageSharp.PixelFormats;
//using System.IdentityModel.Tokens.Jwt;
//using System.Security.Claims;
//using System.Security.Cryptography;
//using System.Text;
//using System.Text.Json;

//namespace HealthCare_.Services.Auth
//{
//    public class AuthService : IAuthService
//    {
//        private readonly UserManager<ApplicationUser> _userManager;
//        private readonly SignInManager<ApplicationUser> _signInManager;
//        private readonly IConfiguration _configuration;
//        private readonly HealthCarePlusContext _context;
//        private readonly IHttpContextAccessor _httpContextAccessor;
//        private readonly IMemoryCache _cache;
//        private readonly IFido2 _fido2;
//        private readonly int MaxRefreshTokensPerUser = 3;
//        private readonly string _jwtKey;
//        private readonly string _refreshHmacKey;
//        private readonly string _refreshAesKey;
//        private readonly RoleManager<ApplicationRole> _roleManager;
//        private readonly ILogger<AuthService> _logger;
//        private readonly CloudinaryService _cloudinary;
//        private readonly IEmailService _emailService;

//        public AuthService(
//            UserManager<ApplicationUser> userManager,
//            SignInManager<ApplicationUser> signInManager,
//            IConfiguration configuration,
//            HealthCarePlusContext context,
//            IHttpContextAccessor httpContextAccessor,
//            IMemoryCache cache,
//            IFido2 fido2,
//            RoleManager<ApplicationRole> roleManager,
//            CloudinaryService cloudinary,
//            IEmailService emailService,
//            ILogger<AuthService> logger)
//        {
//            _userManager = userManager;
//            _signInManager = signInManager;
//            _configuration = configuration;
//            _context = context;
//            _httpContextAccessor = httpContextAccessor;
//            _cache = cache;
//            _fido2 = fido2;
//            _jwtKey = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
//            _refreshHmacKey = _configuration["Jwt:RefreshTokenHmacKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenHmacKey");
//            _refreshAesKey = _configuration["Jwt:RefreshTokenAesKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenAesKey");
//            _roleManager = roleManager;
//            _cloudinary = cloudinary;
//            _logger = logger;
//            _emailService = emailService;

//            if (_jwtKey.Length != 44 || _refreshHmacKey.Length != 44 || _refreshAesKey.Length != 44)
//                throw new InvalidOperationException("JWT keys must be 44 characters (32 bytes Base64-encoded)");
//        }

//        // ====================== REGISTER ======================
//        public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
//        {
//            _logger.LogInformation("RegisterAsync called for email: {Email}", request.Email);

//            var existing = await _userManager.FindByEmailAsync(request.Email);
//            if (existing != null)
//                return (false, new[] { "Email already registered" });

//            var user = new ApplicationUser
//            {
//                UserName = request.Email,
//                Email = request.Email,
//                FullName = request.FullName,
//                Role = request.Role ?? "Patient",
//                Address = "N/A",
//                CreatedAt = DateTime.UtcNow,
//                TwoFactorEnabled = request.TwoFactorEnabled,
//                EmailConfirmed = true
//            };

//            ExternalFile? createdFile = null;
//            string? uploadedPublicId = null;

//            try
//            {
//                if (request.ProfileImageFile != null && request.ProfileImageFile.Length > 0)
//                {
//                    var result = await _cloudinary.UploadFileAsync(request.ProfileImageFile);
//                    createdFile = new ExternalFile
//                    {
//                        FileUrl = result.Url,
//                        PublicId = result.PublicId,
//                        FileType = result.FileType,
//                        FileSize = result.FileSize,
//                        UploadedAt = DateTime.UtcNow,
//                        Category = ExternalFileCategory.Profile
//                    };
//                    uploadedPublicId = result.PublicId;
//                }
//                else
//                {
//                    var (stream, publicId) = await GenerateAndUploadAvatarAsync(request.FullName);
//                    uploadedPublicId = publicId;
//                    createdFile = new ExternalFile
//                    {
//                        FileUrl = stream.Url,
//                        PublicId = publicId,
//                        FileType = "image/png",
//                        FileSize = stream.FileSize,
//                        UploadedAt = DateTime.UtcNow,
//                        Category = ExternalFileCategory.Profile
//                    };
//                }

//                var identityResult = await _userManager.CreateAsync(user, request.Password);
//                if (!identityResult.Succeeded)
//                {
//                    if (uploadedPublicId != null)
//                        await _cloudinary.DeleteFileAsync(uploadedPublicId);
//                    return (false, identityResult.Errors.Select(e => e.Description).ToArray());
//                }

//                await _userManager.AddClaimAsync(user, new Claim(ClaimTypes.Role, user.Role ?? "User"));

//                if (createdFile != null)
//                {
//                    _context.ExternalFiles.Add(createdFile);
//                    await _context.SaveChangesAsync();
//                    user.ProfileImageId = createdFile.FileID;
//                    _context.Entry(user).Property(x => x.ProfileImageId).IsModified = true;
//                    await _context.SaveChangesAsync();
//                }

//                _logger.LogInformation("User registered successfully – ID: {Id}", user.Id);
//                return (true, Array.Empty<string>());
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Registration failed for {Email}", request.Email);
//                if (uploadedPublicId != null)
//                    await _cloudinary.DeleteFileAsync(uploadedPublicId);
//                return (false, new[] { "Registration failed due to server error" });
//            }
//        }

//        // ====================== EXTERNAL LOGIN (Google) ======================
//        public async Task<(string AccessToken, string RefreshToken, string Error)> ExternalLoginAsync(
//            string? deviceInfo = null,
//            string? ipAddress = null)
//        {
//            var httpContext = _httpContextAccessor.HttpContext;
//            if (httpContext == null) return (null!, null!, "No HTTP context");

//            var info = await _signInManager.GetExternalLoginInfoAsync();
//            if (info == null) return (null!, null!, "External login failed");

//            var email = info.Principal.FindFirstValue(ClaimTypes.Email);
//            var fullName = info.Principal.FindFirstValue(ClaimTypes.Name) ?? email?.Split('@')[0];

//            if (string.IsNullOrEmpty(email))
//                return (null!, null!, "Email not provided by provider");

//            var user = await _userManager.FindByEmailAsync(email);

//            // === التسجيل التلقائي إذا المستخدم غير موجود ===
//            if (user == null)
//            {
//                user = new ApplicationUser
//                {
//                    UserName = email,
//                    Email = email,
//                    FullName = fullName,
//                    Role = "Patient",
//                    Address = "N/A",
//                    CreatedAt = DateTime.UtcNow,
//                    EmailConfirmed = true
//                };

//                var createResult = await _userManager.CreateAsync(user);
//                if (!createResult.Succeeded)
//                    return (null!, null!, "Failed to create user");

//                var addLoginResult = await _userManager.AddLoginAsync(user, info);
//                if (!addLoginResult.Succeeded)
//                {
//                    await _userManager.DeleteAsync(user);
//                    return (null!, null!, "Failed to link external login");
//                }

//                var (avatarResult, publicId) = await GenerateAndUploadAvatarAsync(fullName);
//                var file = new ExternalFile
//                {
//                    FileUrl = avatarResult.Url,
//                    PublicId = publicId,
//                    FileType = "image/png",
//                    FileSize = avatarResult.FileSize,
//                    UploadedAt = DateTime.UtcNow,
//                    Category = ExternalFileCategory.Profile
//                };

//                _context.ExternalFiles.Add(file);
//                await _context.SaveChangesAsync();

//                user.ProfileImageId = file.FileID;
//                _context.Entry(user).Property(x => x.ProfileImageId).IsModified = true;
//                await _context.SaveChangesAsync();

//                _logger.LogInformation("Auto-registered Google user: {Email}", email);
//            }
//            else
//            {
//                var existingLogin = await _userManager.FindByLoginAsync(info.LoginProvider, info.ProviderKey);
//                if (existingLogin == null)
//                {
//                    await _userManager.AddLoginAsync(user, info);
//                }
//            }

//            // === إنشاء JWT + Session + Refresh Token ===
//            var (accessToken, jti, _) = await GenerateJwtToken(user);
//            var rawRefresh = GenerateRandomToken();
//            var refreshHash = ComputeHmacSha256Base64(rawRefresh);

//            using var tx = await _context.Database.BeginTransactionAsync();
//            try
//            {
//                var sessions = await _context.UserSessions
//                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
//                    .OrderByDescending(s => s.CreatedAt)
//                    .ToListAsync();

//                if (sessions.Count >= MaxRefreshTokensPerUser)
//                {
//                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
//                    oldest.RevokeSession("Exceeded session limit");
//                    _context.UserSessions.Update(oldest);
//                    await _context.SaveChangesAsync();
//                }

//                var (encryptedToken, tokenSalt) = EncryptAes(rawRefresh);
//                var session = new UserSession
//                {
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo ?? "Google Login",
//                    IpAddress = ipAddress ?? "unknown",
//                    CreatedAt = DateTime.UtcNow,
//                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
//                    LastActivity = DateTime.UtcNow,
//                    IsActive = true,
//                    EncryptedToken = encryptedToken,
//                    Salt = tokenSalt
//                };

//                _context.UserSessions.Add(session);
//                await _context.SaveChangesAsync();

//                var refreshTokenEntity = new RefreshToken
//                {
//                    Token = refreshHash,
//                    Expires = session.ExpiresAt,
//                    CreatedAt = DateTime.UtcNow,
//                    JwtId = jti,
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo,
//                    IpAddress = ipAddress,
//                    UserSessionId = session.Id
//                };

//                _context.RefreshTokens.Add(refreshTokenEntity);
//                await _context.SaveChangesAsync();
//                await tx.CommitAsync();

//                return (accessToken, rawRefresh, string.Empty);
//            }
//            catch (Exception ex)
//            {
//                await tx.RollbackAsync();
//                _logger.LogError(ex, "External login transaction failed");
//                return (null!, null!, "Server error");
//            }
//        }

//        // ====================== LOGIN (مع Email OTP) ======================
//        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
//            LoginRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null,
//            IEmailService? emailService = null)
//        {
//            _logger.LogInformation("LoginAsync called for email: {Email}", request.Email);
//            var user = await _userManager.FindByEmailAsync(request.Email);
//            if (user == null)
//                return (null!, null!, "Email not found");

//            if (!await _userManager.CheckPasswordAsync(user, request.Password))
//                return (null!, null!, "Invalid password");

//            if (user.TwoFactorEnabled)
//            {
//                if (string.IsNullOrEmpty(request.OtpCode))
//                {
//                    if (emailService != null)
//                        await GenerateAndSendOtpAsync(user, emailService);
//                    return (null!, null!, "MFA_OTP_SENT");
//                }

//                var (verified, error) = await VerifyMfaAsync(user.Id, request.OtpCode);
//                if (!verified)
//                    return (null!, null!, error);
//            }

//            if (request.UsePasskey)
//                return (null!, null!, "Passkey authentication required");

//            var (accessToken, jti, _) = await GenerateJwtToken(user);
//            var rawRefresh = GenerateRandomToken();
//            var refreshHash = ComputeHmacSha256Base64(rawRefresh);

//            using var tx = await _context.Database.BeginTransactionAsync();
//            try
//            {
//                var sessions = await _context.UserSessions
//                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
//                    .OrderByDescending(s => s.CreatedAt)
//                    .ToListAsync();

//                if (sessions.Count >= MaxRefreshTokensPerUser)
//                {
//                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
//                    oldest.RevokeSession("Exceeded session limit");
//                    _context.UserSessions.Update(oldest);
//                    await _context.SaveChangesAsync();
//                }

//                var (encryptedToken, tokenSalt) = EncryptAes(rawRefresh);
//                var session = new UserSession
//                {
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo,
//                    IpAddress = ipAddress,
//                    CreatedAt = DateTime.UtcNow,
//                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
//                    LastActivity = DateTime.UtcNow,
//                    IsActive = true,
//                    EncryptedToken = encryptedToken,
//                    Salt = tokenSalt
//                };

//                _context.UserSessions.Add(session);
//                await _context.SaveChangesAsync();

//                var refreshTokenEntity = new RefreshToken
//                {
//                    Token = refreshHash,
//                    Expires = session.ExpiresAt,
//                    CreatedAt = DateTime.UtcNow,
//                    JwtId = jti,
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo,
//                    IpAddress = ipAddress,
//                    UserSessionId = session.Id
//                };

//                _context.RefreshTokens.Add(refreshTokenEntity);
//                await _context.SaveChangesAsync();
//                await tx.CommitAsync();

//                return (accessToken, rawRefresh, string.Empty);
//            }
//            catch (Exception ex)
//            {
//                await tx.RollbackAsync();
//                _logger.LogError(ex, "Login transaction failed");
//                return (null!, null!, "Server error");
//            }
//        }

//        // ====================== LOGOUT ======================
//        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
//        {
//            if (request == null || request.UserId <= 0)
//                return (false, "Invalid request");

//            var session = await _context.UserSessions
//                .FirstOrDefaultAsync(s => s.UserId == request.UserId && s.DeviceInfo == request.DeviceInfo && s.IsActive);

//            if (session == null)
//                return (false, "No active session");

//            session.IsActive = false;
//            session.RevokedAt = DateTime.UtcNow;
//            _context.UserSessions.Update(session);

//            var refreshTokens = await _context.RefreshTokens
//                .Where(rt => rt.UserSessionId == session.Id && !rt.IsRevoked)
//                .ToListAsync();

//            foreach (var rt in refreshTokens)
//            {
//                rt.IsRevoked = true;
//                rt.Revoked = DateTime.UtcNow;
//            }

//            _context.RefreshTokens.UpdateRange(refreshTokens);
//            await _context.SaveChangesAsync();

//            return (true, string.Empty);
//        }

//        // ====================== REFRESH TOKEN ======================
//        public async Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
//            RefreshRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null)
//        {
//            if (request == null || string.IsNullOrEmpty(request.AccessToken) || string.IsNullOrEmpty(request.RefreshToken))
//                return (string.Empty, string.Empty, "Invalid request");

//            var cleanedAccessToken = request.AccessToken.Trim().Replace("Bearer ", "");
//            var tokenHandler = new JwtSecurityTokenHandler();

//            try
//            {
//                var principal = tokenHandler.ValidateToken(cleanedAccessToken, new TokenValidationParameters
//                {
//                    ValidateIssuerSigningKey = true,
//                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
//                    ValidateIssuer = true,
//                    ValidateAudience = true,
//                    ValidIssuer = _configuration["Jwt:Issuer"],
//                    ValidAudience = _configuration["Jwt:Audience"],
//                    ValidateLifetime = false
//                }, out var validatedToken);

//                var jwtToken = validatedToken as JwtSecurityToken;
//                var jti = jwtToken?.Id;
//                var userIdClaim = principal.FindFirst("UserID")?.Value;
//                if (!int.TryParse(userIdClaim, out int userId))
//                    return (string.Empty, string.Empty, "Invalid token");

//                var providedHash = ComputeHmacSha256Base64(request.RefreshToken);

//                using var tx = await _context.Database.BeginTransactionAsync();
//                var stored = await _context.RefreshTokens
//                    .Include(rt => rt.UserSession)
//                    .FirstOrDefaultAsync(rt => rt.Token == providedHash && rt.UserId == userId);

//                if (stored == null || stored.IsUsed || stored.IsRevoked || stored.Expires < DateTime.UtcNow || stored.JwtId != jti)
//                    return (string.Empty, string.Empty, "Invalid refresh token");

//                stored.IsUsed = true;
//                stored.IsRevoked = true;
//                stored.Revoked = DateTime.UtcNow;
//                _context.RefreshTokens.Update(stored);

//                var user = await _userManager.FindByIdAsync(userId.ToString());
//                if (user == null) return (string.Empty, string.Empty, "User not found");

//                var (newAccessToken, newJti, _) = await GenerateJwtToken(user);
//                var newRefreshRaw = GenerateRandomToken();
//                var newRefreshHash = ComputeHmacSha256Base64(newRefreshRaw);

//                var newRefreshEntity = new RefreshToken
//                {
//                    Token = newRefreshHash,
//                    Expires = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
//                    CreatedAt = DateTime.UtcNow,
//                    JwtId = newJti,
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo ?? stored.DeviceInfo,
//                    IpAddress = ipAddress ?? stored.IpAddress,
//                    UserSessionId = stored.UserSessionId
//                };

//                _context.RefreshTokens.Add(newRefreshEntity);

//                if (stored.UserSessionId.HasValue)
//                {
//                    var session = await _context.UserSessions.FindAsync(stored.UserSessionId.Value);
//                    if (session != null)
//                    {
//                        session.LastActivity = DateTime.UtcNow;
//                        _context.UserSessions.Update(session);
//                    }
//                }

//                await _context.SaveChangesAsync();
//                await tx.CommitAsync();

//                return (newAccessToken, newRefreshRaw, string.Empty);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Token validation failed");
//                return (string.Empty, string.Empty, "Invalid token");
//            }
//        }

//        // ====================== ENABLE MFA ======================
//        public async Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId, IEmailService emailService)
//        {
//            var user = await _userManager.FindByIdAsync(userId.ToString());
//            if (user == null) return (false, "", "User not found");
//            if (user.TwoFactorEnabled) return (false, "", "MFA already enabled");

//            user.TwoFactorEnabled = true;
//            var result = await _userManager.UpdateAsync(user);
//            if (!result.Succeeded) return (false, "", "Failed to enable MFA");

//            await GenerateAndSendOtpAsync(user, emailService);
//            return (true, "Check your email for the login code.", "");
//        }

//        // ====================== VERIFY MFA ======================
//        public async Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode)
//        {
//            var otp = await _context.EmailOtps
//                .FirstOrDefaultAsync(o => o.UserId == userId && o.Code == otpCode && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow);

//            if (otp == null) return (false, "Invalid or expired OTP");

//            otp.IsUsed = true;
//            await _context.SaveChangesAsync();

//            var user = await _userManager.FindByIdAsync(userId.ToString());
//            if (user != null)
//                await _userManager.AddClaimAsync(user, new Claim("amr", "mfa"));

//            return (true, "");
//        }

//        // ====================== GENERATE & SEND OTP ======================
//        public async Task GenerateAndSendOtpAsync(ApplicationUser user, IEmailService emailService)
//        {
//            var oldOtps = await _context.EmailOtps
//                .Where(o => o.UserId == user.Id && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow)
//                .ToListAsync();

//            foreach (var old in oldOtps) old.IsUsed = true;

//            var code = new Random().Next(100000, 999999).ToString("D6");
//            var expiresAt = DateTime.UtcNow.AddMinutes(5);

//            var otp = new EmailOTP
//            {
//                UserId = user.Id,
//                Code = code,
//                ExpiresAt = expiresAt,
//                IsUsed = false
//            };

//            _context.EmailOtps.Add(otp);
//            await _context.SaveChangesAsync();

//            var subject = "Your HealthCare Login Code";
//            var html = $@"
//                <div style='font-family: Arial; text-align: center; padding: 20px;'>
//                    <h2>Your One-Time Login Code</h2>
//                    <p>Use this code to complete your login:</p>
//                    <h1 style='font-size: 36px; color: #0e76a8; letter-spacing: 5px;'>{code}</h1>
//                    <p>This code expires in <strong>5 minutes</strong>.</p>
//                    <hr><small>If you didn't request this, ignore this email.</small>
//                </div>";

//            await emailService.SendEmailAsync(user.Email!, subject, html);
//            _logger.LogInformation("OTP sent to {Email}: {Code}", user.Email, code);
//        }

//        // ====================== GENERATE JWT ======================
//        private async Task<(string Token, string Jti, DateTime Expires)> GenerateJwtToken(ApplicationUser user)
//        {
//            var jwtSection = _configuration.GetSection("Jwt");
//            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
//            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
//            var jti = Guid.NewGuid().ToString();

//            var claims = new List<Claim>
//            {
//                new Claim(JwtRegisteredClaimNames.Sub, user.Email ?? string.Empty),
//                new Claim("UserID", user.Id.ToString()),
//                new Claim(JwtRegisteredClaimNames.Jti, jti),
//                new Claim("amr", user.TwoFactorEnabled ? "mfa" : user.PasskeyCredentialId != null ? "passkey" : "pwd")
//            };

//            var roles = await _userManager.GetRolesAsync(user);
//            foreach (var role in roles)
//                claims.Add(new Claim(ClaimTypes.Role, role));

//            var expiryMinutes = Convert.ToDouble(jwtSection["ExpireMinutes"] ?? "15");
//            var token = new JwtSecurityToken(
//                issuer: jwtSection["Issuer"],
//                audience: jwtSection["Audience"],
//                claims: claims,
//                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
//                signingCredentials: creds);

//            return (new JwtSecurityTokenHandler().WriteToken(token), jti, token.ValidTo);
//        }

//        private string GenerateRandomToken()
//        {
//            var randomBytes = new byte[64];
//            using var rng = RandomNumberGenerator.Create();
//            rng.GetBytes(randomBytes);
//            return Convert.ToBase64String(randomBytes);
//        }

//        private string ComputeHmacSha256Base64(string input)
//        {
//            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_refreshHmacKey));
//            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
//            return Convert.ToBase64String(hash);
//        }

//        private (string EncryptedText, string Salt) EncryptAes(string plainText)
//        {
//            if (string.IsNullOrEmpty(plainText)) return (string.Empty, string.Empty);

//            var saltBytes = new byte[16];
//            using (var rng = RandomNumberGenerator.Create())
//                rng.GetBytes(saltBytes);

//            using var derivedKey = new Rfc2898DeriveBytes(_refreshAesKey, saltBytes, 10000, HashAlgorithmName.SHA256);
//            using var aes = Aes.Create();
//            aes.Key = derivedKey.GetBytes(32);
//            aes.GenerateIV();

//            using var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
//            var plainBytes = Encoding.UTF8.GetBytes(plainText);
//            var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

//            var combined = new byte[saltBytes.Length + aes.IV.Length + cipherBytes.Length];
//            Array.Copy(saltBytes, 0, combined, 0, saltBytes.Length);
//            Array.Copy(aes.IV, 0, combined, saltBytes.Length, aes.IV.Length);
//            Array.Copy(cipherBytes, 0, combined, saltBytes.Length + aes.IV.Length, cipherBytes.Length);

//            return (Convert.ToBase64String(combined), Convert.ToBase64String(saltBytes));
//        }

//        // ====================== PASSKEY ======================
//        public async Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, string credentialId, string publicKey)
//        {
//            var user = await _userManager.FindByIdAsync(userId.ToString());
//            if (user == null) return (false, "User not found");

//            user.PasskeyCredentialId = credentialId;
//            user.PasskeyPublicKey = publicKey;
//            await _userManager.UpdateAsync(user);
//            return (true, string.Empty);
//        }

//        public async Task<string> GeneratePasskeyChallengeAsync(string userId)
//        {
//            var challenge = new byte[32];
//            using (var rng = RandomNumberGenerator.Create())
//                rng.GetBytes(challenge);

//            var challengeBase64 = Convert.ToBase64String(challenge);
//            _cache.Set($"passkey_challenge_{userId}", challenge, TimeSpan.FromMinutes(5));
//            return challengeBase64;
//        }

//        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(
//            PasskeyLoginRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null)
//        {
//            if (request == null)
//                return (null!, null!, "Invalid request");

//            var user = await _context.Users
//                .FirstOrDefaultAsync(u => u.PasskeyCredentialId == request.CredentialId);

//            if (user == null)
//                return (null!, null!, "No user found");

//            if (!_cache.TryGetValue($"passkey_challenge_{user.Id}", out byte[]? challenge) || challenge == null)
//                return (null!, null!, "No valid challenge");

//            if (!await VerifyPasskeySignature(request, user.PasskeyPublicKey, challenge, user.Id.ToString()))
//                return (null!, null!, "Invalid signature");

//            _cache.Remove($"passkey_challenge_{user.Id}");

//            var (accessToken, jti, _) = await GenerateJwtToken(user);
//            var rawRefresh = GenerateRandomToken();
//            var refreshHash = ComputeHmacSha256Base64(rawRefresh);

//            using var tx = await _context.Database.BeginTransactionAsync();
//            try
//            {
//                var sessions = await _context.UserSessions
//                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
//                    .OrderByDescending(s => s.CreatedAt)
//                    .ToListAsync();

//                if (sessions.Count >= MaxRefreshTokensPerUser)
//                {
//                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
//                    oldest.RevokeSession("Exceeded session limit");
//                    _context.UserSessions.Update(oldest);
//                    await _context.SaveChangesAsync();
//                }

//                var (encryptedToken, tokenSalt) = EncryptAes(rawRefresh);
//                var session = new UserSession
//                {
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo ?? "Passkey Device",
//                    IpAddress = ipAddress ?? "unknown",
//                    CreatedAt = DateTime.UtcNow,
//                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
//                    LastActivity = DateTime.UtcNow,
//                    IsActive = true,
//                    EncryptedToken = encryptedToken,
//                    Salt = tokenSalt
//                };

//                _context.UserSessions.Add(session);
//                await _context.SaveChangesAsync();

//                var refreshTokenEntity = new RefreshToken
//                {
//                    Token = refreshHash,
//                    Expires = session.ExpiresAt,
//                    CreatedAt = DateTime.UtcNow,
//                    JwtId = jti,
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo,
//                    IpAddress = ipAddress,
//                    UserSessionId = session.Id
//                };

//                _context.RefreshTokens.Add(refreshTokenEntity);
//                await _context.SaveChangesAsync();
//                await tx.CommitAsync();

//                return (accessToken, rawRefresh, string.Empty);
//            }
//            catch (Exception ex)
//            {
//                await tx.RollbackAsync();
//                _logger.LogError(ex, "Passkey login transaction failed");
//                return (null!, null!, "Server error");
//            }
//        }

//        private async Task<bool> VerifyPasskeySignature(
//            PasskeyLoginRequest request,
//            string? publicKeyBase64,
//            byte[] expectedChallenge,
//            string userId)
//        {
//            try
//            {
//                if (string.IsNullOrEmpty(publicKeyBase64))
//                    return false;

//                var credentialPublicKey = WebAuthnHelpers.Base64UrlToByteArray(publicKeyBase64);
//                var authenticatorData = WebAuthnHelpers.Base64UrlToByteArray(request.AuthenticatorData);
//                var clientDataJsonBytes = WebAuthnHelpers.Base64UrlToByteArray(request.ClientDataJson);
//                var clientDataJson = Encoding.UTF8.GetString(clientDataJsonBytes);
//                var signature = WebAuthnHelpers.Base64UrlToByteArray(request.Signature);

//                var clientData = JsonDocument.Parse(clientDataJson);
//                var type = clientData.RootElement.GetProperty("type").GetString();
//                var challengeB64 = clientData.RootElement.GetProperty("challenge").GetString();
//                var origin = clientData.RootElement.GetProperty("origin").GetString();

//                var expectedOrigin = _configuration["WebAuthn:Origin"];
//                var expectedChallengeB64 = Convert.ToBase64String(expectedChallenge);

//                if (type != "webauthn.get" ||
//                    challengeB64 != expectedChallengeB64 ||
//                    origin != expectedOrigin)
//                {
//                    _logger.LogWarning("Passkey validation failed: type={Type}, origin={Origin}, expected={Expected}", type, origin, expectedOrigin);
//                    return false;
//                }

//                using var sha256 = SHA256.Create();
//                var clientDataHash = sha256.ComputeHash(clientDataJsonBytes);

//                var signedData = new byte[authenticatorData.Length + clientDataHash.Length];
//                Buffer.BlockCopy(authenticatorData, 0, signedData, 0, authenticatorData.Length);
//                Buffer.BlockCopy(clientDataHash, 0, signedData, authenticatorData.Length, clientDataHash.Length);

//                using var ecdsa = ECDsa.Create();
//                ecdsa.ImportSubjectPublicKeyInfo(credentialPublicKey, out _);

//                var isValid = ecdsa.VerifyData(signedData, signature, HashAlgorithmName.SHA256);
//                if (!isValid)
//                    _logger.LogWarning("Passkey signature invalid for user {UserId}", userId);

//                return isValid;
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Passkey signature verification failed for user {UserId}", userId);
//                return false;
//            }
//        }

//        public static class WebAuthnHelpers
//        {
//            public static byte[] Base64UrlToByteArray(string base64Url)
//            {
//                string base64 = base64Url.Replace('-', '+').Replace('_', '/');
//                switch (base64.Length % 4)
//                {
//                    case 2: base64 += "=="; break;
//                    case 3: base64 += "="; break;
//                }
//                return Convert.FromBase64String(base64);
//            }
//        }

//        // ====================== ROLES ======================
//        public async Task<int?> GetRoleIdFromDbAsync(string roleName)
//        {
//            var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == roleName);
//            return role?.Id;
//        }

//        public async Task<(bool Succeeded, int? RoleId, string Error)> CreateRoleAsync(string roleName, string description)
//        {
//            var role = new ApplicationRole
//            {
//                Name = roleName,
//                NormalizedName = roleName.ToUpper(),
//                Description = description,
//                CreatedAt = DateTime.UtcNow
//            };

//            var result = await _roleManager.CreateAsync(role);
//            return result.Succeeded
//                ? (true, role.Id, string.Empty)
//                : (false, null, string.Join(", ", result.Errors.Select(e => e.Description)));
//        }

//        // ====================== FORGOT PASSWORD ======================
//        public async Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string? origin = null)
//        {
//            var user = await _userManager.FindByEmailAsync(email);
//            if (user == null || !await _userManager.IsEmailConfirmedAsync(user))
//                return (true, string.Empty); // لا نخبر المستخدم (أمان)

//            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
//            var encodedToken = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(token));

//            // تحديد AppUrl
//            var appUrl = origin
//                         ?? _configuration["AppUrl"]
//                         ?? "http://localhost:3000";

//            var resetLink = $"{appUrl}/reset-password?email={Uri.EscapeDataString(email)}&token={encodedToken}";

//            var subject = "Reset Your HealthCare Password";
//            var html = $@"
//            <!DOCTYPE html>
//            <html lang='en' dir='ltr'>
//            <head>
//                <meta charset='UTF-8'>
//                <meta name='viewport' content='width=device-width, initial-scale=1.0'>
//                <title>Reset Your Password</title>
//                <link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap' rel='stylesheet'>
//                <style>
//                    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
//                    body {{
//                        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
//                        background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
//                        padding: 20px;
//                        color: #1a1a1a;
//                        line-height: 1.6;
//                    }}
//                    .container {{
//                        max-width: 480px;
//                        margin: 40px auto;
//                        background: #ffffff;
//                        border-radius: 20px;
//                        overflow: hidden;
//                        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.08);
//                        animation: fadeIn 0.6s ease-out;
//                    }}
//                    @keyframes fadeIn {{
//                        from {{ opacity: 0; transform: translateY(20px); }}
//                        to {{ opacity: 1; transform: translateY(0); }}
//                    }}
//                    .header {{
//                        background: linear-gradient(120deg, #0e76a8 0%, #1e90ff 100%);
//                        padding: 40px 30px;
//                        text-align: center;
//                        color: white;
//                    }}
//                    .header h1 {{
//                        font-size: 28px;
//                        font-weight: 700;
//                        margin: 0;
//                        letter-spacing: -0.5px;
//                    }}
//                    .header p {{
//                        font-size: 16px;
//                        opacity: 0.9;
//                        margin-top: 8px;
//                    }}
//                    .content {{
//                        padding: 40px 30px;
//                        text-align: center;
//                    }}
//                    .content h2 {{
//                        font-size: 22px;
//                        color: #0e76a8;
//                        margin-bottom: 12px;
//                        font-weight: 600;
//                    }}
//                    .content p {{
//                        font-size: 16px;
//                        color: #444;
//                        margin-bottom: 20px;
//                    }}
//                    .btn {{
//                        display: inline-block;
//                        background: linear-gradient(45deg, #0e76a8, #1e90ff);
//                        color: white;
//                        font-weight: 600;
//                        font-size: 17px;
//                        padding: 16px 40px;
//                        border-radius: 50px;
//                        text-decoration: none;
//                        box-shadow: 0 8px 20px rgba(14, 118, 168, 0.3);
//                        transition: all 0.3s ease;
//                        margin: 10px 0;
//                    }}
//                    .btn:hover {{
//                        transform: translateY(-3px);
//                        box-shadow: 0 12px 25px rgba(14, 118, 168, 0.4);
//                    }}
//                    .expires {{
//                        font-size: 14px;
//                        color: #e74c3c;
//                        font-weight: 500;
//                        margin: 25px 0 15px;
//                    }}
//                    .footer {{
//                        background: #f8f9fa;
//                        padding: 25px;
//                        text-align: center;
//                        font-size: 13px;
//                        color: #777;
//                        border-top: 1px solid #eee;
//                    }}
//                    .footer a {{
//                        color: #0e76a8;
//                        text-decoration: none;
//                    }}
//                    .security {{
//                        margin-top: 20px;
//                        font-size: 13px;
//                        color: #888;
//                    }}
//                    @media (prefers-color-scheme: dark) {{
//                        body {{ background: #0f172a; color: #e2e8f0; }}
//                        .container {{ background: #1e293b; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); }}
//                        .content p {{ color: #cbd5e1; }}
//                        .footer {{ background: #0f172a; border-top: 1px solid #334155; color: #94a3b8; }}
//                    }}
//                    @media (max-width: 480px) {{
//                        .container {{ margin: 20px auto; }}
//                        .header, .content {{ padding: 30px 20px; }}
//                        .btn {{ padding: 14px 32px; font-size: 16px; }}
//                    }}
//                </style>
//            </head>
//            <body>
//                <div class='container'>
//                    <div class='header'>
//                        <h1>HealthCare</h1>
//                        <p>Secure • Modern • Trusted</p>
//                    </div>
//                    <div class='content'>
//                        <h2>Reset Your Password</h2>
//                        <p>Hello <strong>{user.FullName}</strong>,</p>
//                        <p>We received a request to reset your password. Click the button below to proceed.</p>
//                        <a href='{resetLink}' class='btn'>Reset Password</a>
//                        <p class='expires'>This link expires in <strong>1 hour</strong> for your security.</p>
//                        <p class='security'>If you didn't request this, no action is needed your account remains secure.</p>
//                    </div>
//                    <div class='footer'>
//                        <p>© 2025 <strong>HealthCare App</strong>. All rights reserved.</p>
//                        <p><a href='#'>Privacy Policy</a> • <a href='#'>Support</a></p>
//                    </div>
//                </div>
//            </body>
//            </html>";

//            try
//            {
//                await _emailService.SendEmailAsync(email, subject, html);
//                _logger.LogInformation("Password reset link sent to {Email}", email);
//                return (true, string.Empty);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Failed to send password reset email to {Email}", email);
//                return (false, "Failed to send email. Please try again.");
//            }
//        }

//        // ====================== RESET PASSWORD ======================
//        public async Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request)
//        {
//            if (request.NewPassword != request.ConfirmPassword)
//                return (false, "Passwords do not match");

//            var user = await _userManager.FindByEmailAsync(request.Email);
//            if (user == null)
//                return (false, "Invalid reset request");

//            // فك تشفير التوكن
//            byte[] tokenBytes;
//            try
//            {
//                tokenBytes = WebEncoders.Base64UrlDecode(request.Token);
//            }
//            catch
//            {
//                return (false, "Invalid or corrupted token");
//            }

//            var token = Encoding.UTF8.GetString(tokenBytes);

//            var result = await _userManager.ResetPasswordAsync(user, token, request.NewPassword);
//            if (!result.Succeeded)
//            {
//                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
//                _logger.LogWarning("Password reset failed for {Email}: {Errors}", request.Email, errors);
//                return (false, errors);
//            }

//            // إلغاء كل الجلسات والـ Refresh Tokens
//            var sessions = await _context.UserSessions
//                .Where(s => s.UserId == user.Id && !s.IsRevoked)
//                .ToListAsync();

//            foreach (var s in sessions)
//                s.RevokeSession("Password reset - security");

//            var refreshTokens = await _context.RefreshTokens
//                .Where(rt => rt.UserId == user.Id && !rt.IsRevoked)
//                .ToListAsync();

//            foreach (var rt in refreshTokens)
//            {
//                rt.IsRevoked = true;
//                rt.Revoked = DateTime.UtcNow;
//            }

//            await _context.SaveChangesAsync();

//            _logger.LogInformation("Password reset successfully for {Email}", request.Email);
//            return (true, string.Empty);
//        }

//        // ====================== AVATAR GENERATOR ======================
//        private static string GetInitials(string fullName)
//        {
//            var parts = fullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
//            return parts.Length >= 2
//                ? $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}"
//                : parts.Length > 0 ? $"{char.ToUpper(parts[0][0])}" : "U";
//        }

//        private async Task<(CloudinaryUploadResult Result, string PublicId)> GenerateAndUploadAvatarAsync(string fullName)
//        {
//            var initials = GetInitials(fullName);
//            var publicId = $"healthcare_files/avatars/avatar_{initials}_{Guid.NewGuid():N}.png";

//            using var image = new Image<Rgba32>(200, 200);
//            image.Mutate(x => x.BackgroundColor(Color.ParseHex("0e76a8")));

//            var fontCollection = new FontCollection();
//            var fontFamily = fontCollection.Add("C:/Windows/Fonts/arial.ttf");
//            var font = fontFamily.CreateFont(80, FontStyle.Bold);

//            var textOptions = new RichTextOptions(font)
//            {
//                Origin = new PointF(100, 90),
//                HorizontalAlignment = HorizontalAlignment.Center,
//                VerticalAlignment = VerticalAlignment.Center
//            };

//            image.Mutate(x => x.DrawText(textOptions, initials, Color.White));

//            using var ms = new MemoryStream();
//            await image.SaveAsPngAsync(ms);
//            ms.Position = 0;

//            var file = new FormFile(ms, 0, ms.Length, "avatar", $"{initials}.png")
//            {
//                Headers = new HeaderDictionary(),
//                ContentType = "image/png"
//            };

//            var uploadResult = await _cloudinary.UploadFileAsync(file);
//            return (uploadResult, uploadResult.PublicId);
//        }
//    }
//}
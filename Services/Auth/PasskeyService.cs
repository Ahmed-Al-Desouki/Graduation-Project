// File: Services/Auth/PasskeyService.cs
using HealthCare_.Interfaces.IAuth.PKeyAndPassowrd;
using HealthCare_.Interfaces.IAuth.TokenAndCoreAuth;
using HealthCare_.Models.DTOs.AuthModels.Login_register;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace HealthCare_.Services.Auth
{
    public class PasskeyService : IPasskeyService
    {
        private readonly HealthCarePlusContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ITokenService _tokenService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<PasskeyService> _logger;

        public PasskeyService(
            HealthCarePlusContext context,
            UserManager<ApplicationUser> userManager,
            ITokenService tokenService,
            IConfiguration configuration,
            ILogger<PasskeyService> logger)
        {
            _context = context;
            _userManager = userManager;
            _tokenService = tokenService;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> BiometricRefreshAsync(
            BiometricLoginRequest request,
            string deviceInfo,
            string ipAddress)
        {
            _logger.LogInformation("BiometricRefreshAsync START | DeviceId: {DeviceId} | RefreshToken Length: {Len}",
                request.DeviceId, request.RefreshToken?.Length ?? 0);

            // 1. التحقق من البيانات
            if (string.IsNullOrEmpty(request.DeviceId) || string.IsNullOrEmpty(request.RefreshToken))
            {
                _logger.LogWarning("Missing DeviceId or RefreshToken");
                return (null!, null!, "DeviceId and RefreshToken are required.");
            }

            using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                _logger.LogInformation("Searching for UserSession with DeviceInfo = '{DeviceInfo}'", request.DeviceId);

                // 2. جلب الجلسة
                var session = await _context.UserSessions
                    .Include(s => s.User)
                    .Where(s =>
                        s.DeviceInfo == request.DeviceId &&
                        s.IsActive &&
                        !s.IsRevoked &&
                        s.ExpiresAt > DateTime.UtcNow)
                    .OrderByDescending(s => s.CreatedAt)  // أضف السطر ده
                    .FirstOrDefaultAsync();

                if (session == null)
                {
                    _logger.LogWarning("No active session found for DeviceId: {DeviceId}", request.DeviceId);
                    return (null!, null!, "No active biometric session.");
                }

                _logger.LogInformation("Session FOUND | Id: {Id} | UserId: {UserId} | ExpiresAt: {Expires}",
                    session.Id, session.UserId, session.ExpiresAt);

                if (string.IsNullOrEmpty(session.EncryptedToken) || string.IsNullOrEmpty(session.Salt))
                {
                    _logger.LogError("Session missing EncryptedToken or Salt | SessionId: {Id}", session.Id);
                    return (null!, null!, "Invalid session data.");
                }

                _logger.LogInformation("Decrypting token... | EncryptedToken (first 20): {Enc} | Salt (first 10): {Salt}",
                    session.EncryptedToken.Substring(0, Math.Min(20, session.EncryptedToken.Length)) + "...",
                    session.Salt.Substring(0, Math.Min(10, session.Salt.Length)) + "...");

                // 3. فك التشفير
                var (decryptedToken, decryptError) = _tokenService.DecryptAes(session.EncryptedToken, session.Salt);

                if (!string.IsNullOrEmpty(decryptError))
                {
                    _logger.LogError("AES Decryption FAILED | Error: {Error}", decryptError);
                    return (null!, null!, "Decryption failed.");
                }

                _logger.LogInformation("Decrypted Token (first 20): {Dec}", decryptedToken.Substring(0, Math.Min(20, decryptedToken.Length)) + "...");
                _logger.LogInformation("Provided Token (first 20): {Prov}", request.RefreshToken.Substring(0, Math.Min(20, request.RefreshToken.Length)) + "...");

                // 4. مقارنة الـ token
                if (decryptedToken != request.RefreshToken)
                {
                    _logger.LogWarning("TOKEN MISMATCH! | Decrypted != Provided");
                    return (null!, null!, "Invalid refresh token.");
                }

                _logger.LogInformation("TOKEN MATCHED! Proceeding to generate new tokens.");

                var user = session.User;
                if (user == null)
                {
                    _logger.LogError("User is NULL in session | SessionId: {Id}", session.Id);
                    return (null!, null!, "User not found.");
                }

                _logger.LogInformation("User found | Id: {Id} | Email: {Email}", user.Id, user.Email);

                // 5. إبطال الـ Refresh القديم
                var oldRefresh = await _context.RefreshTokens
                    .FirstOrDefaultAsync(rt => rt.UserSessionId == session.Id && !rt.IsRevoked && !rt.IsUsed);

                if (oldRefresh != null)
                {
                    oldRefresh.IsUsed = true;
                    oldRefresh.IsRevoked = true;
                    oldRefresh.Revoked = DateTime.UtcNow;
                    _context.RefreshTokens.Update(oldRefresh);
                    _logger.LogInformation("Old RefreshToken revoked | Id: {Id}", oldRefresh.Id);
                }
                else
                {
                    _logger.LogInformation("No old RefreshToken found to revoke.");
                }

                // 6. تحديث الجلسة
                session.LastActivity = DateTime.UtcNow;
                _logger.LogInformation("Session LastActivity updated to: {Time}", session.LastActivity);

                // 7. توليد JWT + Refresh جديد
                var (newAccessToken, newJti, genError) = await _tokenService.GenerateJwtToken(user);
                if (!string.IsNullOrEmpty(genError))
                {
                    _logger.LogError("JWT Generation failed: {Error}", genError);
                    return (null!, null!, "Token generation failed.");
                }

                var newRawRefresh = _tokenService.GenerateRandomToken();
                _logger.LogInformation("New Raw RefreshToken generated | Length: {Len}", newRawRefresh.Length);

                var newRefreshHash = _tokenService.ComputeHmacSha256Base64(newRawRefresh);
                var (newEncrypted, newSalt) = _tokenService.EncryptAes(newRawRefresh);

                session.EncryptedToken = newEncrypted;
                session.Salt = newSalt;

                _logger.LogInformation("New EncryptedToken and Salt saved to session");

                var newRefreshEntity = new RefreshToken
                {
                    Token = newRefreshHash,
                    Expires = session.ExpiresAt,
                    CreatedAt = DateTime.UtcNow,
                    JwtId = newJti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    UserSessionId = session.Id
                };

                _context.RefreshTokens.Add(newRefreshEntity);
                _logger.LogInformation("New RefreshToken entity added to DB");

                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                _logger.LogInformation("BiometricRefreshAsync SUCCESS | New AccessToken issued");

                return (newAccessToken, newRawRefresh, string.Empty);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                _logger.LogError(ex, "BiometricRefreshAsync FAILED | Exception in transaction");
                return (null!, null!, "Server error.");
            }
        }

        // أضف الدالة دي داخل الكلاس PasskeyService
        public async Task<(bool Success, string Error)> DisableBiometricAsync(
            DisableBiometricRequest request,
            string ipAddress)
        {
            _logger.LogInformation("DisableBiometricAsync START | DeviceId: {DeviceId}", request.DeviceId);

            if (string.IsNullOrEmpty(request.DeviceId))
                return (false, "DeviceId is required.");

            using var tx = await _context.Database.BeginTransactionAsync();
            try
            {
                // جلب آخر جلسة نشطة للجهاز
                var session = await _context.UserSessions
                    .FirstOrDefaultAsync(s =>
                        s.DeviceInfo == request.DeviceId &&
                        s.IsActive &&
                        !s.IsRevoked &&
                        s.ExpiresAt > DateTime.UtcNow);

                if (session == null)
                {
                    _logger.LogInformation("No active biometric session to disable for DeviceId: {DeviceId}", request.DeviceId);
                    return (true, "Biometric already disabled or no session found.");
                }

                // إبطال الجلسة
                session.IsActive = false;
                session.IsRevoked = true;
                session.RevokedAt = DateTime.UtcNow;
                session.RevokedByIp = ipAddress;
                _context.UserSessions.Update(session);

                // إبطال كل الـ RefreshTokens المرتبطة
                var refreshTokens = await _context.RefreshTokens
                    .Where(rt => rt.UserSessionId == session.Id && !rt.IsRevoked)
                    .ToListAsync();

                foreach (var rt in refreshTokens)
                {
                    rt.IsRevoked = true;
                    rt.Revoked = DateTime.UtcNow;
                    rt.RevokedByIp = ipAddress;
                }

                _context.RefreshTokens.UpdateRange(refreshTokens);

                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                _logger.LogInformation("Biometric DISABLED | SessionId: {Id} | Device: {Device}", session.Id, request.DeviceId);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                _logger.LogError(ex, "DisableBiometricAsync FAILED");
                return (false, "Server error.");
            }
        }
    }
}
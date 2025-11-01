using HealthCare_.Services.Auth.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using System.Security.Cryptography;
using HealthCare_.Models.sharedModels;

namespace HealthCare_.Services.Auth
{
    public class PasskeyService : IPasskeyService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly HealthCarePlusContext _context;
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _configuration;
        private readonly ITokenService _tokenService;
        private readonly ILogger<PasskeyService> _logger;

        public PasskeyService(
            UserManager<ApplicationUser> userManager,
            HealthCarePlusContext context,
            IMemoryCache cache,
            IConfiguration configuration,
            ITokenService tokenService,
            ILogger<PasskeyService> logger)
        {
            _userManager = userManager;
            _context = context;
            _cache = cache;
            _configuration = configuration;
            _tokenService = tokenService;
            _logger = logger;
        }

        public async Task<(bool Succeeded, string Error, string? AccessToken)> RegisterPasskeyAsync(
                int userId,
                string credentialId,
                string publicKey)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null) return (false, "User not found", null);

            user.PasskeyCredentialId = credentialId;
            user.PasskeyPublicKey = publicKey;
            await _userManager.UpdateAsync(user);

            var (accessToken, _, error) = await _tokenService.GenerateJwtToken(
                user,
                TimeSpan.FromDays(30)
            );

            if (!string.IsNullOrEmpty(error))
                return (true, string.Empty, null); 

            return (true, string.Empty, accessToken);
        }

        public async Task<string> GeneratePasskeyChallengeAsync(string userId)
        {
            var challenge = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
                rng.GetBytes(challenge);

            var challengeBase64 = Convert.ToBase64String(challenge);
            _cache.Set($"passkey_challenge_{userId}", challenge, TimeSpan.FromMinutes(5));
            return challengeBase64;
        }

        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(
            PasskeyLoginRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            if (request == null)
                return (null!, null!, "Invalid request");

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.PasskeyCredentialId == request.CredentialId);

            if (user == null)
                return (null!, null!, "No user found");

            if (!_cache.TryGetValue($"passkey_challenge_{user.Id}", out byte[]? challenge) || challenge == null)
                return (null!, null!, "No valid challenge");

            if (!await VerifyPasskeySignature(request, user.PasskeyPublicKey, challenge, user.Id.ToString()))
                return (null!, null!, "Invalid signature");

            _cache.Remove($"passkey_challenge_{user.Id}");

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
                    DeviceInfo = deviceInfo ?? "Passkey Device",
                    IpAddress = ipAddress ?? "unknown",
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
                _logger.LogError(ex, "Passkey login transaction failed");
                return (null!, null!, "Server error");
            }
        }

        private async Task<bool> VerifyPasskeySignature(
            PasskeyLoginRequest request,
            string? publicKeyBase64,
            byte[] expectedChallenge,
            string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(publicKeyBase64))
                    return false;

                var credentialPublicKey = WebAuthnHelpers.Base64UrlToByteArray(publicKeyBase64);
                var authenticatorData = WebAuthnHelpers.Base64UrlToByteArray(request.AuthenticatorData);
                var clientDataJsonBytes = WebAuthnHelpers.Base64UrlToByteArray(request.ClientDataJson);
                var clientDataJson = Encoding.UTF8.GetString(clientDataJsonBytes);
                var signature = WebAuthnHelpers.Base64UrlToByteArray(request.Signature);

                var clientData = JsonDocument.Parse(clientDataJson);
                var type = clientData.RootElement.GetProperty("type").GetString();
                var challengeB64 = clientData.RootElement.GetProperty("challenge").GetString();
                var origin = clientData.RootElement.GetProperty("origin").GetString();

                var expectedOrigin = _configuration["WebAuthn:Origin"];
                var expectedChallengeB64 = Convert.ToBase64String(expectedChallenge);

                if (type != "webauthn.get" ||
                    challengeB64 != expectedChallengeB64 ||
                    origin != expectedOrigin)
                {
                    _logger.LogWarning("Passkey validation failed: type={Type}, origin={Origin}, expected={Expected}", type, origin, expectedOrigin);
                    return false;
                }

                using var sha256 = SHA256.Create();
                var clientDataHash = sha256.ComputeHash(clientDataJsonBytes);

                var signedData = new byte[authenticatorData.Length + clientDataHash.Length];
                Buffer.BlockCopy(authenticatorData, 0, signedData, 0, authenticatorData.Length);
                Buffer.BlockCopy(clientDataHash, 0, signedData, authenticatorData.Length, clientDataHash.Length);

                using var ecdsa = ECDsa.Create();
                ecdsa.ImportSubjectPublicKeyInfo(credentialPublicKey, out _);

                var isValid = ecdsa.VerifyData(signedData, signature, HashAlgorithmName.SHA256);
                if (!isValid)
                    _logger.LogWarning("Passkey signature invalid for user {UserId}", userId);

                return isValid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Passkey signature verification failed for user {UserId}", userId);
                return false;
            }
        }

        public static class WebAuthnHelpers
        {
            public static byte[] Base64UrlToByteArray(string base64Url)
            {
                string base64 = base64Url.Replace('-', '+').Replace('_', '/');
                switch (base64.Length % 4)
                {
                    case 2: base64 += "=="; break;
                    case 3: base64 += "="; break;
                }
                return Convert.FromBase64String(base64);
            }
        }
    }
}
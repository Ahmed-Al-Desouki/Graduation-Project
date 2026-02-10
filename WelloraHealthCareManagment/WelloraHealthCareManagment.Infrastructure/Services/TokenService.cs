using Google.Apis.Auth.OAuth2.Requests;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Authentication.Tokens;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<TokenService> _logger;
        private readonly string _jwtKey;
        private readonly string _refreshHmacKey;
        private readonly string _refreshAesKey;
        private readonly string _issuer;
        private readonly string _audience;
        private readonly int _accessTokenExpireMinutes;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IRevokedTokenRepository _revokedTokenRepository;
        private readonly IUserSessionRepository _sessionRepository;
        private readonly IUserRepository _userRepository;

        public TokenService(
            IConfiguration configuration,
            ILogger<TokenService> logger,
            IRefreshTokenRepository refreshTokenRepository,
            IRevokedTokenRepository revokedTokenRepository,
            IUserSessionRepository sessionRepository,
            IUserRepository userRepository)
        {
            _configuration = configuration;
            _logger = logger;
            _refreshTokenRepository = refreshTokenRepository;
            _revokedTokenRepository = revokedTokenRepository;
            _sessionRepository = sessionRepository;
            _userRepository = userRepository;

            // Load and validate configuration
            _jwtKey = configuration["Jwt:Key"]
                ?? throw new InvalidOperationException("Missing Jwt:Key in configuration");
            _refreshHmacKey = configuration["Jwt:RefreshTokenHmacKey"]
                ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenHmacKey");
            _refreshAesKey = configuration["Jwt:RefreshTokenAesKey"]
                ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenAesKey");
            _issuer = configuration["Jwt:Issuer"]
                ?? throw new InvalidOperationException("Missing Jwt:Issuer");
            _audience = configuration["Jwt:Audience"]
                ?? throw new InvalidOperationException("Missing Jwt:Audience");

            if (!int.TryParse(configuration["Jwt:ExpireMinutes"], out _accessTokenExpireMinutes))
                _accessTokenExpireMinutes = 1440; // Default 15 minutes

            // Validate key lengths (must be 44 chars = 32 bytes Base64)
            if (_jwtKey.Length != 44 || _refreshHmacKey.Length != 44 || _refreshAesKey.Length != 44)
                throw new InvalidOperationException("JWT keys must be 44 characters (32 bytes Base64-encoded)");
        }

        public async Task<(string AccessToken, string Jti, DateTime Expires)> GenerateJwtTokenAsync(
            ApplicationUser user,
            TimeSpan? expiry = null)
        {
            var expires = DateTime.UtcNow.Add(expiry ?? TimeSpan.FromMinutes(_accessTokenExpireMinutes));
            var jti = Guid.NewGuid().ToString();

            var claims = new List<Claim>
            {
                new Claim("UserID", user.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim("Name", user.FullName),
                new Claim("Email", user.Email!),
                new Claim("Role", user.Role),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim(JwtRegisteredClaimNames.Sub, user.Email!),
                new Claim(JwtRegisteredClaimNames.Jti, jti)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            _logger.LogInformation("Generated JWT for user {UserId}, JTI: {Jti}", user.Id, jti);

            return await Task.FromResult((tokenString, jti, expires));
        }

        public async Task<(string MfaToken, string Jti, DateTime Expires)> GenerateMfaTokenAsync(
            ApplicationUser user)
        {
            var expires = DateTime.UtcNow.AddMinutes(15); // MFA tokens are short-lived
            var jti = Guid.NewGuid().ToString();

            var claims = new List<Claim>
            {
                new Claim("UserID", user.Id.ToString()),
                new Claim("Email", user.Email!),
                new Claim("mfa_pending", "true"),
                new Claim(JwtRegisteredClaimNames.Jti, jti)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            _logger.LogInformation("Generated MFA token for user {UserId}", user.Id);

            return await Task.FromResult((tokenString, jti, expires));
        }

        public string GenerateRandomToken()
        {
            var randomBytes = new byte[64]; // 512 bits
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            return Convert.ToBase64String(randomBytes);
        }

        public string ComputeHmacSha256Base64(string input)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_refreshHmacKey));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToBase64String(hash);
        }

        public (string EncryptedText, string Salt) EncryptAes(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
                return (string.Empty, string.Empty);

            try
            {
                // Generate random salt
                var saltBytes = new byte[16];
                using (var rng = RandomNumberGenerator.Create())
                    rng.GetBytes(saltBytes);

                // Derive key from AES key + salt
                using var derivedKey = new Rfc2898DeriveBytes(
                    _refreshAesKey,
                    saltBytes,
                    10000,
                    HashAlgorithmName.SHA256);

                using var aes = Aes.Create();
                aes.Key = derivedKey.GetBytes(32); // 256-bit key
                aes.GenerateIV();

                // Encrypt
                using var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
                var plainBytes = Encoding.UTF8.GetBytes(plainText);
                var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

                // Combine: Salt + IV + Cipher
                var combined = new byte[saltBytes.Length + aes.IV.Length + cipherBytes.Length];
                Array.Copy(saltBytes, 0, combined, 0, saltBytes.Length);
                Array.Copy(aes.IV, 0, combined, saltBytes.Length, aes.IV.Length);
                Array.Copy(cipherBytes, 0, combined, saltBytes.Length + aes.IV.Length, cipherBytes.Length);

                return (Convert.ToBase64String(combined), Convert.ToBase64String(saltBytes));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "AES encryption failed");
                return (string.Empty, string.Empty);
            }
        }

        public (string PlainText, string Error) DecryptAes(string cipherTextBase64, string saltBase64)
        {
            if (string.IsNullOrEmpty(cipherTextBase64) || string.IsNullOrEmpty(saltBase64))
                return (string.Empty, "Invalid input");

            try
            {
                var cipherBytes = Convert.FromBase64String(cipherTextBase64);
                var saltBytes = Convert.FromBase64String(saltBase64);

                // Derive same key
                using var derivedKey = new Rfc2898DeriveBytes(
                    _refreshAesKey,
                    saltBytes,
                    10000,
                    HashAlgorithmName.SHA256);

                using var aes = Aes.Create();
                aes.Key = derivedKey.GetBytes(32);

                // Extract IV and encrypted data
                var iv = new byte[16];
                var encrypted = new byte[cipherBytes.Length - 16 - saltBytes.Length];
                Array.Copy(cipherBytes, saltBytes.Length, iv, 0, 16);
                Array.Copy(cipherBytes, saltBytes.Length + 16, encrypted, 0, encrypted.Length);

                aes.IV = iv;

                // Decrypt
                using var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
                var plainBytes = decryptor.TransformFinalBlock(encrypted, 0, encrypted.Length);

                return (Encoding.UTF8.GetString(plainBytes), string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "AES decryption failed");
                return (string.Empty, "Decryption failed");
            }
        }

        public ClaimsPrincipal? ValidateJwtToken(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_jwtKey);

            try
            {
                var principal = tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _issuer,
                    ValidAudience = _audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero // No tolerance for expired tokens
                }, out _);

                return principal;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "JWT validation failed");
                return null;
            }
        }

        public string? GetJtiFromToken(string token)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwtToken = handler.ReadJwtToken(token);
                return jwtToken.Id;
            }
            catch
            {
                return null;
            }
        }

        public async Task<RefreshTokenResponse> RefreshTokenAsync(
            RefreshRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            if (request == null || string.IsNullOrEmpty(request.AccessToken) || string.IsNullOrEmpty(request.RefreshToken))
            {
                return RefreshTokenResponse.Failed("Invalid request");
            }

            var cleanedAccessToken = request.AccessToken.Trim().Replace("Bearer ", "");
            var tokenHandler = new JwtSecurityTokenHandler();

            try
            {
                // 1. Validate Access Token (without lifetime validation)
                var principal = tokenHandler.ValidateToken(cleanedAccessToken, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _issuer,
                    ValidAudience = _audience,
                    ValidateLifetime = false // Don't validate lifetime - token might be expired
                }, out var validatedToken);

                var jwtToken = validatedToken as JwtSecurityToken;
                var jti = jwtToken?.Id;
                var userIdClaim = principal.FindFirst("UserID")?.Value;

                if (!int.TryParse(userIdClaim, out int userId))
                {
                    return RefreshTokenResponse.Failed("Invalid token");
                }

                // 2. Verify Refresh Token
                var providedHash = ComputeHmacSha256Base64(request.RefreshToken);

                var stored = await _refreshTokenRepository.GetByTokenHashAsync(providedHash, userId);

                if (stored == null || stored.IsUsed || stored.IsRevoked || stored.Expires < DateTime.UtcNow || stored.JwtId != jti)
                {
                    return RefreshTokenResponse.Failed("Invalid refresh token");
                }

                // 3. Mark old refresh token as used
                stored.IsUsed = true;
                stored.IsRevoked = true;
                stored.Revoked = DateTime.UtcNow;
                await _refreshTokenRepository.UpdateAsync(stored);

                // 4. Revoke old access token (add Jti to revoked list)
                if (!string.IsNullOrEmpty(jti))
                {
                    await _revokedTokenRepository.AddAsync(new RevokedToken
                    {
                        Jti = jti,
                        Expires = DateTime.UtcNow.AddMinutes(_accessTokenExpireMinutes),
                        RevokedAt = DateTime.UtcNow,
                        UserId = userId
                    });
                }

                // 5. Get user
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null)
                {
                    return RefreshTokenResponse.Failed("User not found");
                }

                // 6. Generate new tokens
                var (newAccessToken, newJti, _) = await GenerateJwtTokenAsync(user);
                var newRefreshRaw = GenerateRandomToken();
                var newRefreshHash = ComputeHmacSha256Base64(newRefreshRaw);

                // 7. Create new refresh token entity
                var newRefreshEntity = new RefreshToken
                {
                    Token = newRefreshHash,
                    Expires = DateTime.UtcNow.AddDays(30), // TODO: Get from config
                    CreatedAt = DateTime.UtcNow,
                    JwtId = newJti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo ?? stored.DeviceInfo,
                    IpAddress = ipAddress ?? stored.IpAddress,
                    UserSessionId = stored.UserSessionId
                };

                await _refreshTokenRepository.AddAsync(newRefreshEntity);

                // 8. Update session last activity
                if (stored.UserSessionId.HasValue)
                {
                    var session = await _sessionRepository.GetByIdAsync(stored.UserSessionId.Value);
                    if (session != null)
                    {
                        session.LastActivity = DateTime.UtcNow;
                        await _sessionRepository.UpdateAsync(session);
                    }
                }

                _logger.LogInformation("Token refreshed successfully for user {UserId}", userId);

                return RefreshTokenResponse.Success(newAccessToken, newRefreshRaw);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Token refresh failed");
                return RefreshTokenResponse.Failed("Invalid token");
            }
        }
    }
}
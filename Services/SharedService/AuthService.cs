using HealthCare_.Interfaces;
using HealthCare_.Models.AuthModels;
using HealthCare_.Models.Context;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.SharedModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
namespace HealthCare_.Services.SharedService
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        private readonly HealthCarePlusContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly int MaxRefreshTokensPerUser = 3;
        private readonly string _jwtKey;
        private readonly string _refreshHmacKey;
        private readonly string _refreshAesKey;
        public AuthService(
        UserManager<ApplicationUser> userManager,
        IConfiguration configuration,
        HealthCarePlusContext context,
        IHttpContextAccessor httpContextAccessor)
        {
            _userManager = userManager;
            _configuration = configuration;
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _jwtKey = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
            _refreshHmacKey = _configuration["Jwt:RefreshTokenHmacKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenHmacKey");
            _refreshAesKey = _configuration["Jwt:RefreshTokenAesKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenAesKey");
        }
        // ---------------- Register ----------------
        public async Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request)
        {
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
                return (false, new[] { "Email already registered" });
            var user = new ApplicationUser
            {
                UserName = request.Email,
                Email = request.Email,
                FName = request.FName,
                LName = request.LName,
                Role = request.Role,
                Address = request.Address ?? "Not Provided",
                ProfileImagePath = request.ProfileImagePath ?? "default.png",
                CreatedAt = DateTime.UtcNow,
            };
            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
                return (false, result.Errors.Select(e => e.Description).ToArray());
            await _userManager.AddClaimAsync(user, new Claim(ClaimTypes.Role, user.Role ?? "User"));
            return (true, Array.Empty<string>());
        }
        // ---------------- Login ----------------
        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
        LoginRequest request,
        string deviceInfo = null,
        string ipAddress = null)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null) return (null, null, "Email not found");
            if (!await _userManager.CheckPasswordAsync(user, request.Password))
                return (null, null, "Invalid password");
            var accessToken = GenerateJwtToken(user, out string jti, out DateTime expiresAt);
            var rawRefresh = GenerateRandomToken();
            var refreshHash = ComputeHmacSha256Base64(rawRefresh);
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
                }
                var session = new UserSession
                {
                    UserId = user.Id,
                    DeviceInfo = deviceInfo,
                    IpAddress = ipAddress,
                    CreatedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
                    LastActivity = DateTime.UtcNow,
                    IsActive = true,
                    EncryptedToken = EncryptAes(rawRefresh) // Store encrypted refresh token here
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
                    UserSessionId = session.Id // Link RefreshToken to UserSession
                };
                _context.RefreshTokens.Add(refreshTokenEntity);
                await _context.SaveChangesAsync();
                await tx.CommitAsync();
            }
            var encryptedForClient = EncryptAes(rawRefresh);
            return (accessToken, encryptedForClient, null);
        }
        // ---------------- Logout ----------------
        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            try
            {
                if (request == null || request.UserId <= 0)
                    return (false, "Invalid logout request");
                var session = await _context.UserSessions
                .Where(s => s.UserId == request.UserId && s.DeviceInfo == request.DeviceInfo && s.IsActive)
                .OrderByDescending(s => s.LastActivity)
                .FirstOrDefaultAsync();
                if (session == null)
                    return (false, "No active session found for this user/device");
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
                return (true, null);
            }
            catch (Exception ex)
            {
                return (false, $"Logout failed: {ex.Message}");
            }
        }
        // ---------------- Refresh Token ----------------
        public async Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
        RefreshRequest request,
        string deviceInfo = null,
        string ipAddress = null)
        {
            if (request == null || string.IsNullOrEmpty(request.AccessToken) || string.IsNullOrEmpty(request.RefreshToken))
                return (null, null, "Access token and refresh token are required.");
            var tokenHandler = new JwtSecurityTokenHandler();
            ClaimsPrincipal principal;
            SecurityToken validatedToken;
            try
            {
                principal = tokenHandler.ValidateToken(request.AccessToken, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidAudience = _configuration["Jwt:Audience"],
                    ValidateLifetime = false // Allow expired JWT for refresh
                }, out validatedToken);
            }
            catch
            {
                return (null, null, "Invalid access token");
            }
            var jwtToken = validatedToken as JwtSecurityToken;
            var jti = jwtToken?.Id;
            var userIdClaim = principal.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return (null, null, "Invalid token claims");
            // Decrypt refresh token
            string decryptedRefresh;
            try
            {
                decryptedRefresh = DecryptAes(request.RefreshToken);
            }
            catch
            {
                return (null, null, "Invalid refresh token format");
            }
            var providedHash = ComputeHmacSha256Base64(decryptedRefresh);
            using (var tx = await _context.Database.BeginTransactionAsync())
            {
                var stored = await _context.RefreshTokens
                .Include(rt => rt.UserSession)
                .Where(rt => rt.Token == providedHash && rt.UserId == userId)
                .FirstOrDefaultAsync();
                if (stored == null)
                    return (null, null, "Invalid refresh token");
                if (stored.IsUsed || stored.IsRevoked)
                    return (null, null, "Refresh token is no longer valid");
                if (stored.Expires < DateTime.UtcNow)
                    return (null, null, "Refresh token expired");
                if (stored.JwtId != jti)
                    return (null, null, "Refresh token does not match access token");
                // Mark old token as used/revoked
                stored.IsUsed = true;
                stored.IsRevoked = true;
                stored.Revoked = DateTime.UtcNow;
                _context.RefreshTokens.Update(stored);
                // Generate new tokens
                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null)
                {
                    await tx.RollbackAsync();
                    return (null, null, "User not found");
                }
                var newAccessToken = GenerateJwtToken(user, out string newJti, out DateTime newAccessExpires);
                var newRawRefresh = GenerateRandomToken();
                var newHash = ComputeHmacSha256Base64(newRawRefresh);
                var newRefreshEntity = new RefreshToken
                {
                    Token = newHash,
                    Expires = DateTime.UtcNow.AddDays(Convert.ToDouble(_configuration["Jwt:RefreshTokenExpireDays"] ?? "7")),
                    CreatedAt = DateTime.UtcNow,
                    JwtId = newJti,
                    UserId = user.Id,
                    DeviceInfo = deviceInfo ?? stored.DeviceInfo,
                    IpAddress = ipAddress ?? stored.IpAddress,
                    UserSessionId = stored.UserSessionId // Reuse the same UserSession
                };
                _context.RefreshTokens.Add(newRefreshEntity);
                await _context.SaveChangesAsync();
                // Update session with new encrypted refresh token
                if (stored.UserSessionId.HasValue)
                {
                    var session = await _context.UserSessions.FindAsync(stored.UserSessionId.Value);
                    if (session != null)
                    {
                        session.LastActivity = DateTime.UtcNow;
                        session.EncryptedToken = EncryptAes(newRawRefresh); // Update encrypted token
                        _context.UserSessions.Update(session);
                    }
                }
                await _context.SaveChangesAsync();
                await tx.CommitAsync();
                var encryptedForClient = EncryptAes(newRawRefresh);
                return (newAccessToken, encryptedForClient, null);
            }
        }
        // ---------------- Helpers ----------------
        private string GenerateJwtToken(ApplicationUser user, out string jti, out DateTime expires)
        {
            var jwtSection = _configuration.GetSection("Jwt");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            jti = Guid.NewGuid().ToString();
            var claims = new List<Claim>
{
new Claim(JwtRegisteredClaimNames.Sub, user.Email ?? string.Empty),
new Claim("UserID", user.Id.ToString()),
new Claim(ClaimTypes.Role, user.Role ?? string.Empty),
new Claim(JwtRegisteredClaimNames.Jti, jti)
};
            var expiryMinutes = Convert.ToDouble(jwtSection["ExpireMinutes"] ?? "15");
            var token = new JwtSecurityToken(
            issuer: jwtSection["Issuer"],
            audience: jwtSection["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
            signingCredentials: creds
            );
            expires = token.ValidTo;
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        private string GenerateRandomToken()
        {
            var randomBytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            return Convert.ToBase64String(randomBytes);
        }
        private string ComputeHmacSha256Base64(string input)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_refreshHmacKey));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToBase64String(hash);
        }
        private string EncryptAes(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return string.Empty;
            // Use a fixed salt for key derivation
            byte[] salt = Encoding.UTF8.GetBytes("FixedSaltForAesKeyDerivation1234"); // 32-byte salt (can be changed, but keep it secret and fixed)
                                                                                      // Derive a 32-byte key from the configuration string using PBKDF2
            using var derivedKey = new Rfc2898DeriveBytes(_refreshAesKey, salt, 10000, HashAlgorithmName.SHA256); // 10000 iterations for security
            using var aes = Aes.Create();
            aes.Key = derivedKey.GetBytes(32); // 32 bytes for AES-256
            aes.GenerateIV();
            using var encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
            var plainBytes = Encoding.UTF8.GetBytes(plainText);
            var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
            var combined = new byte[aes.IV.Length + cipherBytes.Length];
            Array.Copy(aes.IV, 0, combined, 0, aes.IV.Length);
            Array.Copy(cipherBytes, 0, combined, aes.IV.Length, cipherBytes.Length);
            return Convert.ToBase64String(combined);
        }
        private string DecryptAes(string encrypted)
        {
            if (string.IsNullOrEmpty(encrypted)) return string.Empty;
            // Use the same fixed salt for key derivation
            byte[] salt = Encoding.UTF8.GetBytes("FixedSaltForAesKeyDerivation1234"); // Must match the salt in EncryptAes
                                                                                      // Derive the same 32-byte key
            using var derivedKey = new Rfc2898DeriveBytes(_refreshAesKey, salt, 10000, HashAlgorithmName.SHA256);
            var combined = Convert.FromBase64String(encrypted);
            using var aes = Aes.Create();
            aes.Key = derivedKey.GetBytes(32);
            var ivSize = aes.BlockSize / 8;
            var iv = new byte[ivSize];
            Array.Copy(combined, 0, iv, 0, iv.Length);
            aes.IV = iv;
            var cipher = new byte[combined.Length - iv.Length];
            Array.Copy(combined, iv.Length, cipher, 0, cipher.Length);
            using var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
            var plain = decryptor.TransformFinalBlock(cipher, 0, cipher.Length);
            return Encoding.UTF8.GetString(plain);
        }
    }
}
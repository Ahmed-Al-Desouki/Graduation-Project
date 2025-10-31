using HealthCare_.Services.Auth.Interfaces;


namespace HealthCare_.Services.Auth
{
    
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;
        private readonly HealthCarePlusContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly string _jwtKey;
        private readonly string _refreshHmacKey;
        private readonly string _refreshAesKey;
        private readonly int MaxRefreshTokensPerUser = 3;
        private readonly ILogger<TokenService> _logger;

        public TokenService(IConfiguration configuration, HealthCarePlusContext context, UserManager<ApplicationUser> userManager, ILogger<TokenService> logger)
        {
            _configuration = configuration;
            _context = context;
            _userManager = userManager;
            _jwtKey = configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
            _refreshHmacKey = configuration["Jwt:RefreshTokenHmacKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenHmacKey");
            _refreshAesKey = configuration["Jwt:RefreshTokenAesKey"] ?? throw new InvalidOperationException("Missing Jwt:RefreshTokenAesKey");

            if (_jwtKey.Length != 44 || _refreshHmacKey.Length != 44 || _refreshAesKey.Length != 44)
                throw new InvalidOperationException("JWT keys must be 44 characters (32 bytes Base64-encoded)");
            _logger = logger;
        }

        public async Task<(string AccessToken, string Jti, string? Error)> GenerateJwtToken(
                ApplicationUser user,
                TimeSpan? expiry = null)
        {
            try
            {
                var claims = new List<Claim>
        {
                new Claim("UserID", user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.UserName ?? user.Email!),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

                var roles = await _userManager.GetRolesAsync(user);
                claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
                var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                // استخدم expiry أو الافتراضي
                var expires = DateTime.UtcNow.Add(expiry ?? TimeSpan.FromMinutes(
                    Convert.ToDouble(_configuration["Jwt:ExpireMinutes"] ?? "60")
                ));

                var token = new JwtSecurityToken(
                    issuer: _configuration["Jwt:Issuer"],
                    audience: _configuration["Jwt:Audience"],
                    claims: claims,
                    expires: expires,
                    signingCredentials: creds
                );

                var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
                var jti = token.Claims.First(c => c.Type == JwtRegisteredClaimNames.Jti).Value;

                return (accessToken, jti, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "JWT generation failed for user {UserId}", user.Id);
                return (string.Empty, string.Empty, "Token generation failed");
            }
        }

        public string GenerateRandomToken()
        {
            var randomBytes = new byte[64];
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
            if (string.IsNullOrEmpty(plainText)) return (string.Empty, string.Empty);

            var saltBytes = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
                rng.GetBytes(saltBytes);

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

        public async Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
            RefreshRequest request,
            string? deviceInfo = null,
            string? ipAddress = null)
        {
            if (request == null || string.IsNullOrEmpty(request.AccessToken) || string.IsNullOrEmpty(request.RefreshToken))
                return (string.Empty, string.Empty, "Invalid request");

            var cleanedAccessToken = request.AccessToken.Trim().Replace("Bearer ", "");
            var tokenHandler = new JwtSecurityTokenHandler();

            try
            {
                var principal = tokenHandler.ValidateToken(cleanedAccessToken, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidAudience = _configuration["Jwt:Audience"],
                    ValidateLifetime = false
                }, out var validatedToken);

                var jwtToken = validatedToken as JwtSecurityToken;
                var jti = jwtToken?.Id;
                var userIdClaim = principal.FindFirst("UserID")?.Value;
                if (!int.TryParse(userIdClaim, out int userId))
                    return (string.Empty, string.Empty, "Invalid token");

                var providedHash = ComputeHmacSha256Base64(request.RefreshToken);

                using var tx = await _context.Database.BeginTransactionAsync();
                var stored = await _context.RefreshTokens
                    .Include(rt => rt.UserSession)
                    .FirstOrDefaultAsync(rt => rt.Token == providedHash && rt.UserId == userId);

                if (stored == null || stored.IsUsed || stored.IsRevoked || stored.Expires < DateTime.UtcNow || stored.JwtId != jti)
                    return (string.Empty, string.Empty, "Invalid refresh token");

                stored.IsUsed = true;
                stored.IsRevoked = true;
                stored.Revoked = DateTime.UtcNow;
                _context.RefreshTokens.Update(stored);

                var user = await _userManager.FindByIdAsync(userId.ToString());
                if (user == null) return (string.Empty, string.Empty, "User not found");

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

                if (stored.UserSessionId.HasValue)
                {
                    var session = await _context.UserSessions.FindAsync(stored.UserSessionId.Value);
                    if (session != null)
                    {
                        session.LastActivity = DateTime.UtcNow;
                        _context.UserSessions.Update(session);
                    }
                }

                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                return (newAccessToken, newRefreshRaw, string.Empty);
            }
            catch (Exception ex)
            {
                return (string.Empty, string.Empty, "Invalid token");
            }
        }
    }
}
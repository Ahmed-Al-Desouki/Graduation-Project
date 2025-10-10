using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace HealthCare_.Services.SharedService
{
    public interface IAuthService
    {
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(LoginRequest request);
        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(RefreshRequest request);
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);
    }

    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        private readonly HealthCarePlusContext _context;

        public AuthService(UserManager<ApplicationUser> userManager, IConfiguration configuration, HealthCarePlusContext context)
        {
            _userManager = userManager;
            _configuration = configuration;
            _context = context;
        }

        private readonly int MaxRefreshTokensPerUser = 3;

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
                ProfileImagePath = "default.png",
                CreatedAt = DateTime.UtcNow,
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
                return (false, result.Errors.Select(e => e.Description).ToArray());

            await _userManager.AddClaimAsync(user, new Claim(ClaimTypes.Role, user.Role));
            return (true, Array.Empty<string>());
        }

        // ---------------- Login ----------------
        public async Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(LoginRequest request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null) return (null, null, "Email not found");

            if (!await _userManager.CheckPasswordAsync(user, request.Password))
                return (null, null, "Invalid password");

            var accessToken = GenerateJwtToken(user, out string jti, out DateTime expires);
            var refreshToken = await GenerateAndStoreRefreshToken(user.Id, jti);

            return (accessToken, refreshToken, null);
        }

        // ---------------- Refresh Token ----------------
        public async Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(RefreshRequest request)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtSettings = _configuration.GetSection("Jwt");

            // قراءة الـ Access Token بدون التحقق من صلاحيته
            var validationParams = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"])),
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                ValidateLifetime = false
            };

            ClaimsPrincipal principal;
            SecurityToken validatedToken;
            try
            {
                principal = tokenHandler.ValidateToken(request.AccessToken, validationParams, out validatedToken);
            }
            catch { return (null, null, "Invalid access token"); }

            var jwtToken = validatedToken as JwtSecurityToken;
            var jti = jwtToken.Id;
            var userIdClaim = principal.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return (null, null, "Invalid token claims");

            var storedRefresh = await _context.RefreshTokens.FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken);
            if (storedRefresh == null || storedRefresh.IsUsed || storedRefresh.IsRevoked || storedRefresh.Expires < DateTime.UtcNow)
                return (null, null, "Invalid or expired refresh token");

            if (storedRefresh.JwtId != jti)
                return (null, null, "Refresh token does not match access token");

            storedRefresh.IsUsed = true;
            storedRefresh.Revoked = DateTime.UtcNow;
            _context.RefreshTokens.Update(storedRefresh);
            await _context.SaveChangesAsync();

            var user = await _userManager.FindByIdAsync(userId.ToString());
            var newAccessToken = GenerateJwtToken(user, out string newJti, out DateTime newExpires);
            var newRefreshToken = await GenerateAndStoreRefreshToken(user.Id, newJti);

            return (newAccessToken, newRefreshToken, null);
        }

        // ---------------- Logout ----------------
        public async Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request)
        {
            if (!string.IsNullOrEmpty(request.RefreshToken))
            {
                var stored = await _context.RefreshTokens.FirstOrDefaultAsync(r => r.Token == request.RefreshToken);
                if (stored != null && !stored.IsRevoked)
                {
                    stored.IsRevoked = true;
                    stored.Revoked = DateTime.UtcNow;
                    _context.RefreshTokens.Update(stored);
                }
            }

            if (!string.IsNullOrEmpty(request.AccessToken))
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var jwtSettings = _configuration.GetSection("Jwt");
                try
                {
                    var principal = tokenHandler.ValidateToken(request.AccessToken, new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"])),
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidIssuer = jwtSettings["Issuer"],
                        ValidAudience = jwtSettings["Audience"],
                        ValidateLifetime = false
                    }, out SecurityToken validatedToken);

                    var jwtToken = validatedToken as JwtSecurityToken;
                    if (jwtToken != null)
                    {
                        var jti = jwtToken.Id;
                        var exp = DateTime.UtcNow;
                        if (jwtToken.Payload.Exp != null)
                            exp = DateTimeOffset.FromUnixTimeSeconds(Convert.ToInt64(jwtToken.Payload.Exp)).UtcDateTime;

                        _context.RevokedTokens.Add(new RevokedToken
                        {
                            Jti = jti,
                            Expires = exp,
                            RevokedAt = DateTime.UtcNow
                        });
                    }
                }
                catch { }
            }

            await _context.SaveChangesAsync();
            return (true, null);
        }

        // ---------------- Helpers ----------------
        private string GenerateJwtToken(ApplicationUser user, out string jti, out DateTime expires)
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            jti = Guid.NewGuid().ToString();

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email ?? string.Empty),
                new Claim("UserID", user.Id.ToString()),
                new Claim(ClaimTypes.Role, user.Role ?? string.Empty),
                new Claim(JwtRegisteredClaimNames.Jti, jti)
            };

            var expiryMinutes = Convert.ToDouble(jwtSettings["ExpireMinutes"]);
            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
                signingCredentials: creds
            );

            expires = token.ValidTo;
            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private async Task<string> GenerateAndStoreRefreshToken(int userId, string jwtId)
        {
            var randomBytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            var refreshTokenString = Convert.ToBase64String(randomBytes);

            // حذف الأقدم إذا وصلنا للحد الأقصى
            var tokens = await _context.RefreshTokens
                .Where(t => t.UserId == userId && !t.IsRevoked)
                .OrderBy(t => t.Created)
                .ToListAsync();

            if (tokens.Count >= MaxRefreshTokensPerUser)
            {
                var toRemove = tokens.Take(tokens.Count - MaxRefreshTokensPerUser + 1);
                _context.RefreshTokens.RemoveRange(toRemove);
            }

            var refreshToken = new RefreshToken
            {
                Token = refreshTokenString,
                Expires = DateTime.UtcNow.AddDays(7),
                JwtId = jwtId,
                UserId = userId,
                Created = DateTime.UtcNow
            };

            _context.RefreshTokens.Add(refreshToken);
            await _context.SaveChangesAsync();

            return refreshTokenString;
        }
    }
}
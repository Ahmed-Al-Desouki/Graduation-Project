//using HealthCare_.Interfaces.IAuth;

//using HealthCare_.Models.sharedModels;
//using HealthCare_.Services.Auth.Interfaces;


//namespace HealthCare_.Services.Auth
//{
//    public class ExternalAuthService : IExternalAuthService
//    {
//        private readonly SignInManager<ApplicationUser> _signInManager;
//        private readonly UserManager<ApplicationUser> _userManager;
//        private readonly HealthCarePlusContext _context;
//        private readonly IHttpContextAccessor _httpContextAccessor;
//        private readonly ITokenService _tokenService;
//        private readonly IAvatarService _avatarService;
//        private readonly IConfiguration _configuration;
//        private readonly ILogger<ExternalAuthService> _logger;

//        public ExternalAuthService(
//            SignInManager<ApplicationUser> signInManager,
//            UserManager<ApplicationUser> userManager,
//            HealthCarePlusContext context,
//            IHttpContextAccessor httpContextAccessor,
//            ITokenService tokenService,
//            IAvatarService avatarService,
//            IConfiguration configuration,
//            ILogger<ExternalAuthService> logger)
//        {
//            _signInManager = signInManager;
//            _userManager = userManager;
//            _context = context;
//            _httpContextAccessor = httpContextAccessor;
//            _tokenService = tokenService;
//            _avatarService = avatarService;
//            _configuration = configuration;
//            _logger = logger;
//        }

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

//                var (avatarResult, publicId) = await _avatarService.GenerateAndUploadAvatarAsync(fullName);
//                var file = new ExternalFile
//                {
//                    FileUrl = avatarResult.Url,
//                    PublicId = publicId,
//                    FileType = "image/png",
//                    FileSize = avatarResult.FileSize,
//                    UploadedAt = DateTime.UtcNow,        
//                    CategoryValue = "Profile",
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

//            var (accessToken, jti, _) = await _tokenService.GenerateJwtToken(user);
//            var rawRefresh = _tokenService.GenerateRandomToken();
//            var refreshHash = _tokenService.ComputeHmacSha256Base64(rawRefresh);

//            using var tx = await _context.Database.BeginTransactionAsync();
//            try
//            {
//                var sessions = await _context.UserSessions
//                    .Where(s => s.UserId == user.Id && !s.IsRevoked)
//                    .OrderByDescending(s => s.CreatedAt)
//                    .ToListAsync();

//                if (sessions.Count >= 3)
//                {
//                    var oldest = sessions.OrderBy(s => s.CreatedAt).First();
//                    oldest.RevokeSession("Exceeded session limit");
//                    _context.UserSessions.Update(oldest);
//                    await _context.SaveChangesAsync();
//                }

//                var (encryptedToken, tokenSalt) = _tokenService.EncryptAes(rawRefresh);
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
//    }
//}
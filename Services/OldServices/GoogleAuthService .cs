//using global::HealthCare_.Models.sharedModels;
//using global::HealthCare_.Services.Auth.Interfaces;
//using Google.Apis.Auth;
//using HealthCare_.Interfaces.IAuth;

//namespace HealthCare_.Services.Auth
//{
//        public class GoogleAuthService : IGoogleAuthService
//        {
//            private readonly UserManager<ApplicationUser> _userManager;
//            private readonly ITokenService _tokenService;
//            private readonly IAuthCoreService _authCoreService;
//            private readonly IMfaService _mfaService;
//            private readonly IEmailService _emailService;
//            private readonly HealthCarePlusContext _context;

//            public GoogleAuthService(
//                UserManager<ApplicationUser> userManager,
//                ITokenService tokenService,
//                IAuthCoreService authCoreService,
//                IMfaService mfaService,
//                IEmailService emailService,
//                HealthCarePlusContext context)
//            {
//                _userManager = userManager;
//                _tokenService = tokenService;
//                _authCoreService = authCoreService;
//                _mfaService = mfaService;
//                _emailService = emailService;
//                _context = context;
//            }

//            public async Task<GoogleAuthResult> LoginOrRegisterAsync(string idToken, string deviceInfo, string ipAddress)
//            {
//                GoogleJsonWebSignature.Payload payload;
//                try
//                {
//                    payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
//                    {
//                        Audience = new[] { "YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com" }
//                    });
//                }
//                catch
//                {
//                    return new GoogleAuthResult { Success = false, Error = "Invalid Google ID token" };
//                }

//                // 1️⃣ Find or create user
//                var user = await _userManager.Users
//                    .Include(u => u.Logins)
//                    .FirstOrDefaultAsync(u => u.Logins.Any(l => l.LoginProvider == "Google" && l.ProviderKey == payload.Subject));

//                if (user == null)
//                {
//                    user = await _userManager.FindByEmailAsync(payload.Email);
//                    if (user == null)
//                    {
//                        user = new ApplicationUser
//                        {
//                            UserName = payload.Email,
//                            Email = payload.Email,
//                            EmailConfirmed = true,
//                            FullName = payload.Name ?? payload.Email,
//                            Role = "Patient"
//                        };
//                        var createResult = await _userManager.CreateAsync(user);
//                        if (!createResult.Succeeded)
//                            return new GoogleAuthResult { Success = false, Error = "Failed to create user" };
//                    }

//                    await _userManager.AddLoginAsync(user, new UserLoginInfo("Google", payload.Subject, "Google"));
//                }

//                // 2️⃣ MFA Check
//                if (user.TwoFactorEnabled)
//                {
//                    await _mfaService.GenerateAndSendOtpAsync(user, _emailService);

//                    return new GoogleAuthResult
//                    {
//                        Success = true,
//                        RequiresMfa = true,
//                        MfaToken = Guid.NewGuid().ToString()
//                    };
//                }

//                // 3️⃣ Create UserSession
//                var refreshToken = _tokenService.GenerateRefreshToken();
//                var encryptedToken = _tokenService.EncryptToken(refreshToken);

//                var session = new UserSession
//                {
//                    UserId = user.Id,
//                    DeviceInfo = deviceInfo,
//                    IpAddress = ipAddress,
//                    EncryptedToken = encryptedToken,
//                    RefreshTokenHash = _tokenService.ComputeHmacSha256Base64(refreshToken),
//                    CreatedAt = DateTime.UtcNow,
//                    LastActivity = DateTime.UtcNow,
//                    ExpiresAt = DateTime.UtcNow.AddDays(7),
//                    IsActive = true
//                };

//                _context.UserSessions.Add(session);
//                await _context.SaveChangesAsync();

//                // 4️⃣ Generate JWT
//                var accessToken = _tokenService.GenerateJwtToken(user);

//                return new GoogleAuthResult
//                {
//                    Success = true,
//                    AccessToken = accessToken,
//                    RefreshToken = refreshToken,
//                    SessionId = session.Id
//                };
//            }
//        }


//}

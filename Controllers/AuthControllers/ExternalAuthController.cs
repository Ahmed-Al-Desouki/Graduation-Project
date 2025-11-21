using Google.Apis.Auth;
using HealthCare_.Models.sharedModels;
using HealthCare_.Services.Auth;
using HealthCare_.Services.Auth.Interfaces;


namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ExternalAuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IAuthCoreService _authCoreService;
        private readonly IEmailService _emailService;
        private readonly HealthCarePlusContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ExternalAuthController> _logger;

        public ExternalAuthController(
            UserManager<ApplicationUser> userManager,
            IAuthCoreService authCoreService,
            IEmailService emailService,
            HealthCarePlusContext context,
            IConfiguration configuration,
            ILogger<ExternalAuthController> logger)
        {
            _userManager = userManager;
            _authCoreService = authCoreService;
            _emailService = emailService;
            _context = context;
            _configuration = configuration;
            _logger = logger;
        }

        // Endpoint Flutter بعد ما يحصل Google login
        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            _logger.LogInformation("GoogleLogin endpoint called.");

            if (request == null || string.IsNullOrEmpty(request.IdToken))
            {
                _logger.LogWarning("Invalid GoogleLogin request: Missing IdToken.");
                return BadRequest(new { error = "Invalid request" });
            }

            _logger.LogInformation("Validating Google IdToken...");

            // 1. تحقق من Google token
            var payload = await GoogleTokenValidator.ValidateAsync(request.IdToken, _configuration, _logger);
            if (payload == null || string.IsNullOrEmpty(payload.Email))
            {
                _logger.LogWarning("Google token invalid or email missing.");
                return BadRequest(new { error = "Invalid Google token" });
            }

            _logger.LogInformation("Google token valid for email: {Email}", payload.Email);

            // 2. Normalize and validate requested role
            var requestedRole = (request.Role ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(requestedRole)) requestedRole = "Patient";

            var allowedRoles = new[] { "Patient", "Doctor" };
            if (!allowedRoles.Any(r => r.Equals(requestedRole, StringComparison.OrdinalIgnoreCase)))
            {
                _logger.LogWarning("Invalid role '{Role}', defaulting to Patient.", requestedRole);
                requestedRole = "Patient";
            }

            var email = payload.Email!;
            _logger.LogInformation("Requested role: {Role}", requestedRole);

            // 3. Device info + IP
            var rawDeviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var deviceInfo = rawDeviceInfo.Length > 256 ? rawDeviceInfo[..256] : rawDeviceInfo;

            string ipAddress;
            if (Request.Headers.ContainsKey("X-Forwarded-For"))
            {
                ipAddress = Request.Headers["X-Forwarded-For"].ToString().Split(',').FirstOrDefault()?.Trim() ?? "unknown";
            }
            else
            {
                ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            }

            _logger.LogInformation("DeviceInfo='{DeviceInfo}', IP='{IP}'", deviceInfo, ipAddress);

            // 4. Create / Lookup user transactionally
            ApplicationUser user = null!;
            using (var tx = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    user = await _userManager.FindByEmailAsync(email);

                    if (user == null)
                    {
                        _logger.LogInformation("Creating new user for email {Email}", email);

                        user = new ApplicationUser
                        {
                            UserName = email,
                            Email = email,
                            EmailConfirmed = true,
                            FullName = string.IsNullOrEmpty(payload.Name) ? email : payload.Name,
                            Role = requestedRole,
                            CreatedAt = DateTime.UtcNow
                        };

                        var createResult = await _userManager.CreateAsync(user);
                        if (!createResult.Succeeded)
                        {
                            _logger.LogWarning("User creation failed for {Email}: {Errors}",
                                email, string.Join(", ", createResult.Errors.Select(e => e.Description)));

                            return BadRequest(new
                            {
                                success = false,
                                error = string.Join(", ", createResult.Errors.Select(e => e.Description))
                            });
                        }

                        try
                        {
                            var addRoleResult = await _userManager.AddToRoleAsync(user, requestedRole);
                            if (!addRoleResult.Succeeded)
                            {
                                _logger.LogWarning("AddToRoleAsync failed for user {UserId}: {Errors}",
                                    user.Id, string.Join(", ", addRoleResult.Errors.Select(e => e.Description)));
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Exception in AddToRoleAsync for user {UserId}", user.Id);
                        }

                        // Create profile
                        if (requestedRole.Equals("Patient", StringComparison.OrdinalIgnoreCase))
                        {
                            if (!await _context.Patients.AnyAsync(p => p.PatientID == user.Id))
                            {
                                _logger.LogInformation("Creating Patient profile for user {UserId}", user.Id);

                                _context.Patients.Add(new HealthCare_.Models.PatientModels.Patient
                                {
                                    PatientID = user.Id,
                                    DateOfBirth = DateTime.Today.AddYears(-25),
                                    Gender = "Unknown",
                                    CreatedAt = DateTime.UtcNow,
                                    CurrentLocation = "Not Specified"
                                });
                            }
                        }
                        else if (requestedRole.Equals("Doctor", StringComparison.OrdinalIgnoreCase))
                        {
                            if (!await _context.Doctors.AnyAsync(d => d.DoctorID == user.Id))
                            {
                                _logger.LogInformation("Creating Doctor profile for user {UserId}", user.Id);

                                _context.Doctors.Add(new HealthCare_.Models.DoctorModels.Doctor
                                {
                                    DoctorID = user.Id,
                                    Specialization = "General",
                                    YearsOfExperience = 0,
                                    ConsultationFee = 0,
                                    IsActive = true,
                                    CreatedAt = DateTime.UtcNow
                                });
                            }
                        }

                        await _context.SaveChangesAsync();
                    }
                    else
                    {
                        _logger.LogInformation("Existing user found: {Email}", email);

                        if (!string.IsNullOrEmpty(request.Role) &&
                            !user.Role.Equals(requestedRole, StringComparison.OrdinalIgnoreCase))
                        {
                            _logger.LogWarning("Role mismatch for existing user {Email}. Requested={Req}, Actual={Act}",
                                email, requestedRole, user.Role);

                            await tx.RollbackAsync();
                            return BadRequest(new
                            {
                                success = false,
                                error = "Role mismatch for existing account. Please use the role upgrade process."
                            });
                        }
                    }

                    await tx.CommitAsync();
                    _logger.LogInformation("User creation/lookup transaction committed for {Email}", email);
                }
                catch (Exception ex)
                {
                    await tx.RollbackAsync();
                    _logger.LogError(ex, "Error during GoogleLogin user transaction for {Email}", email);
                    return StatusCode(500, new { success = false, error = "Server error" });
                }
            }

            // 5. AuthCoreService unified login
            _logger.LogInformation("Calling AuthCoreService.ExternalLoginAsync for user {UserId}", user.Id);

            var result = await _authCoreService.ExternalLoginAsync(user, deviceInfo, ipAddress, _emailService);

            // 6. MFA Pending?
            //if (result.Error?.StartsWith("MFA_PENDING|") == true)
            //{
            //    var mfaToken = result.Error.Substring("MFA_PENDING|".Length);

            //    _logger.LogInformation("MFA required for user {UserId}", user.Id);

            //    return Ok(new
            //    {
            //        success = true,
            //        status = "pending",
            //        requiresMfa = true,
            //        mfaToken
            //    });
            //}

            // 7. Success — return tokens
            _logger.LogInformation("Google login successful for user {UserId}", user.Id);

            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
        }



        // Google token validator - uses configuration for audiences and logs errors
        public static class GoogleTokenValidator
        {
            public static async Task<GooglePayload?> ValidateAsync(string idToken, IConfiguration config, ILogger? logger = null)
            {
                try
                {
                    var audiences = config.GetSection("Auth:GoogleClientIds").Get<List<string>>()
                                    ?? new List<string>();

                    if (audiences.Count == 0)
                    {
                        logger?.LogWarning("No GoogleClientIds configured under Auth:GoogleClientIds. Token validation may fail.");
                    }

                    var settings = new GoogleJsonWebSignature.ValidationSettings
                    {
                        Audience = audiences
                    };

                    var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

                    return new GooglePayload
                    {
                        Email = payload.Email,
                        Name = payload.Name
                    };
                }
                catch (Exception ex)
                {
                    logger?.LogWarning(ex, "Google token validation failed");
                    return null; // التوكن مش صحيح
                }
            }
        }

        public class GooglePayload
        {
            public string Email { get; set; } = string.Empty;
            public string? Name { get; set; }
        }
    }
}
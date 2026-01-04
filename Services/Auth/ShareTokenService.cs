using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Services.Auth
{
    public class ShareTokenService : IShareTokenService
    {
        private readonly IConfiguration _configuration;
        private readonly HealthCarePlusContext _db;
        private readonly ILogger<ShareTokenService> _logger;
        private readonly IMedicalProfileService _mediicalProfileService;

        public ShareTokenService(
            IConfiguration configuration,
            ILogger<ShareTokenService> logger,
            HealthCarePlusContext db,
            IMedicalProfileService mediicalProfileService)
        {
            _configuration = configuration;
            _logger = logger;
            _db = db;
            _mediicalProfileService = mediicalProfileService;
        }

        public string GenerateMedicalHistoryShareToken(
            int patientId,
            int medicalHistoryId)
        {
            _logger.LogInformation(
                "Generating MedicalHistory share token | PatientId: {PatientId} | MedicalHistoryId: {HistoryId}",
                patientId,
                medicalHistoryId);

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["JwtShare:ShareKey"]!));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim("PatientID", patientId.ToString()),
                new Claim("MedicalHistoryID", medicalHistoryId.ToString()),
                new Claim("Scope", "MedicalHistory.Read")
            };

            var expires = DateTime.UtcNow.AddMinutes(
                Convert.ToDouble(_configuration["JwtShare:ShareExpireMinutes"] ?? "10"));

            var token = new JwtSecurityToken(
                issuer: _configuration["JwtShare:Issuer"],     
                audience: _configuration["JwtShare:Audience"],
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            _logger.LogInformation(
                "MedicalHistory share token generated successfully | ExpiresAt: {Expires}",
                expires);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public async Task<MedicalProfileResponse> GetMedicalProfileFromShareTokenAsync(string token)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtShare:ShareKey"]!));
            var tokenHandler = new JwtSecurityTokenHandler();
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = key,
                ValidateIssuer = true,
                ValidIssuer = _configuration["JwtShare:Issuer"],
                ValidateAudience = true,
                ValidAudience = _configuration["JwtShare:Audience"],
                ClockSkew = TimeSpan.Zero
            };

            var principal = tokenHandler.ValidateToken(token, validationParameters, out _);

            var patientId = int.Parse(principal.FindFirst("PatientID")!.Value);

            // بدل الرجوع للـ DbContext مباشرة، استدعي MedicalProfileService
            return await _mediicalProfileService.GetMedicalProfileByPatientIdAsync(patientId);
        }

    }
}


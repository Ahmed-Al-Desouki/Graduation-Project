// Infrastructure/Services/ShareTokenService.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class ShareTokenService : IShareTokenService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ShareTokenService> _logger;
        private readonly GetCompleteMedicalProfileQueryHandler _getCompleteMedicalProfileHandler;


        public ShareTokenService(
            IConfiguration configuration,
            ILogger<ShareTokenService> logger,
            GetCompleteMedicalProfileQueryHandler getCompleteMedicalProfileHandler)
        {
            _configuration = configuration;
            _logger = logger;
            _getCompleteMedicalProfileHandler = getCompleteMedicalProfileHandler;
        }

        public string GenerateMedicalHistoryShareToken(int patientId, int medicalHistoryId)
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
            _logger.LogInformation("Validating share token...");

            // 1. Validate Token وجيب الـ PatientId منه
            var patientId = ValidateAndGetPatientId(token);

            _logger.LogInformation(
                "Share token validated successfully | PatientId: {PatientId}",
                patientId);

            var profileQuery = new GetCompleteMedicalProfileQuery(patientId);
            return await _getCompleteMedicalProfileHandler.HandleAsync(profileQuery);
        }

        public int ValidateAndGetPatientId(string token)
        {
            var principal = ValidateToken(token);

            return int.Parse(principal.FindFirst("PatientID")!.Value);
        }

        public int ValidateAndGetMedicalHistoryId(string token)
        {
            var principal = ValidateToken(token);

            return int.Parse(principal.FindFirst("MedicalHistoryID")!.Value);
        }

        private ClaimsPrincipal ValidateToken(string token)
        {
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["JwtShare:ShareKey"]!));

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

            return tokenHandler.ValidateToken(token, validationParameters, out _);
        }

    }
}

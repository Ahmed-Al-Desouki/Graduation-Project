// Application/UseCases/ShareToken/Queries/GetMedicalProfileFromShareToken/GetMedicalProfileFromShareTokenQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GetMedicalProfileFromShareToken;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GetMedicalProfileFromShareToken
{
    public class GetMedicalProfileFromShareTokenQueryHandler
    {
        private readonly IShareTokenService _shareTokenService;
        private readonly GetCompleteMedicalProfileQueryHandler _getCompleteMedicalProfileHandler;
        private readonly ILogger<GetMedicalProfileFromShareTokenQueryHandler> _logger;

        public GetMedicalProfileFromShareTokenQueryHandler(
            IShareTokenService shareTokenService,
            GetCompleteMedicalProfileQueryHandler getCompleteMedicalProfileHandler,
            ILogger<GetMedicalProfileFromShareTokenQueryHandler> logger)
        {
            _shareTokenService = shareTokenService;
            _getCompleteMedicalProfileHandler = getCompleteMedicalProfileHandler;
            _logger = logger;
        }

        public async Task<MedicalProfileResponse> HandleAsync(
            GetMedicalProfileFromShareTokenQuery query)
        {
            _logger.LogInformation("Validating share token...");

            // 1. Validate token وجيب الـ PatientId منه
            var patientId = _shareTokenService.ValidateAndGetPatientId(query.Token);

            _logger.LogInformation(
                "Share token validated successfully | PatientId: {PatientId}",
                patientId);

            // 2. استخدام الـ GetCompleteMedicalProfile Handler اللي عملناه قبل كده
            var profileQuery = new GetCompleteMedicalProfileQuery(patientId);
            return await _getCompleteMedicalProfileHandler.HandleAsync(profileQuery);
        }
    }
}
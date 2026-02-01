// Application/UseCases/ShareToken/Queries/GenerateShareToken/GenerateShareTokenQueryHandler.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GenerateMedicalShareToken
{
    public class GenerateShareTokenQueryHandler
    {
        private readonly IShareTokenService _shareTokenService;
        private readonly ILogger<GenerateShareTokenQueryHandler> _logger;

        public GenerateShareTokenQueryHandler(
            IShareTokenService shareTokenService,
            ILogger<GenerateShareTokenQueryHandler> logger)
        {
            _shareTokenService = shareTokenService;
            _logger = logger;
        }

        public string HandleAsync(GenerateShareTokenQuery query)
        {
            _logger.LogInformation(
                "Generating share token | PatientId: {PatientId} | MedicalHistoryId: {HistoryId}",
                query.PatientId,
                query.MedicalHistoryId);

            var token = _shareTokenService.GenerateMedicalHistoryShareToken(
                query.PatientId,
                query.MedicalHistoryId);

            return token;
        }
    }
}
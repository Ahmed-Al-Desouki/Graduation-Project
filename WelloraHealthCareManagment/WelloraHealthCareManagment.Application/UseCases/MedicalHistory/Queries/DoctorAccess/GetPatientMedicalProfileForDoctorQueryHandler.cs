// Application/UseCases/MedicalHistory/Queries/DoctorAccess/GetPatientMedicalProfileForDoctorQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.DoctorAccess;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;

public class GetPatientMedicalProfileForDoctorQueryHandler
{
    private readonly IMedicalHistoryAccessRepository _accessRepository;
    private readonly GetCompleteMedicalProfileQueryHandler _profileHandler;
    private readonly ILogger<GetPatientMedicalProfileForDoctorQueryHandler> _logger;

    public GetPatientMedicalProfileForDoctorQueryHandler(
        IMedicalHistoryAccessRepository accessRepository,
        GetCompleteMedicalProfileQueryHandler profileHandler,
        ILogger<GetPatientMedicalProfileForDoctorQueryHandler> logger)
    {
        _accessRepository = accessRepository;
        _profileHandler = profileHandler;
        _logger = logger;
    }

    public async Task<MedicalProfileResponse> HandleAsync(
        GetPatientMedicalProfileForDoctorQuery query,
        CancellationToken ct = default)
    {
        _logger.LogInformation(
        "Searching for grant - PatientId: {PatientId}, DoctorId: {DoctorId}, AppointmentId: {AppointmentId}, Now: {Now}",
        query.PatientId, query.DoctorId, query.AppointmentId, DateTime.UtcNow);

        var grant = await _accessRepository.GetActiveGrantAsync(
            query.PatientId, query.DoctorId, query.AppointmentId, ct);

        _logger.LogInformation("Grant found: {GrantFound}, IsActive: {IsActive}, CanView: {CanView}",
            grant != null, grant?.IsActive(), grant?.CanViewMedicalHistory);

        if (grant == null || !grant.IsActive())
            throw new UnauthorizedAccessException("No active grant");

        if (!grant.CanViewMedicalHistory)
            throw new UnauthorizedAccessException("No medical history permission");

        try
        {
            var log = MedicalHistoryAccessLog.Create(
                grant.Id, query.DoctorId, query.PatientId, "View", "MedicalProfile");
            await _accessRepository.AddLogAsync(log, ct);
            _logger.LogInformation("Log saved successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to save access log - continuing anyway");
            // متوقفش العملية بسبب الـ log
        }

        return await _profileHandler.HandleAsync(
            new GetCompleteMedicalProfileQuery(query.PatientId));
    }
}
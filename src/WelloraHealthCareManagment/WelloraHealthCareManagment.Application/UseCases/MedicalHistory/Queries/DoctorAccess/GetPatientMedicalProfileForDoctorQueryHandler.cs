// Application/UseCases/MedicalHistory/Queries/DoctorAccess/GetPatientMedicalProfileForDoctorQueryHandler.cs
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.DoctorAccess;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

public class GetPatientMedicalProfileForDoctorQueryHandler
{
    private readonly IMedicalHistoryAccessRepository _accessRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly INotificationService _notificationService;
    private readonly GetCompleteMedicalProfileQueryHandler _profileHandler;
    private readonly ILogger<GetPatientMedicalProfileForDoctorQueryHandler> _logger;

    public GetPatientMedicalProfileForDoctorQueryHandler(
        IMedicalHistoryAccessRepository accessRepository,
        IAppointmentRepository appointmentRepository,
        INotificationService notificationService,
        GetCompleteMedicalProfileQueryHandler profileHandler,
        ILogger<GetPatientMedicalProfileForDoctorQueryHandler> logger)
    {
        _accessRepository = accessRepository;
        _appointmentRepository = appointmentRepository;
        _notificationService = notificationService;
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

        var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(query.AppointmentId, ct);
        var doctorName = appointment?.Doctor?.User?.FullName;
        var doctorLabel = string.IsNullOrWhiteSpace(doctorName)
            ? $"Doctor #{query.DoctorId}"
            : doctorName.StartsWith("Dr.", StringComparison.OrdinalIgnoreCase)
                ? $"{doctorName} (Doctor #{query.DoctorId})"
                : $"Dr. {doctorName} (Doctor #{query.DoctorId})";
        var appointmentDateTime = appointment?.TimeSlot == null
            ? null
            : appointment.TimeSlot.SlotDate
                .Add(appointment.TimeSlot.StartTime)
                .ToString("dddd, dd MMM yyyy 'at' hh:mm tt", System.Globalization.CultureInfo.InvariantCulture);

        if (grant == null || !grant.IsActive())
        {
            await TryNotifyPatientAboutAccessRequestAsync(query, appointment, doctorLabel, appointmentDateTime, ct);
            throw new UnauthorizedAccessException("No active grant");
        }

        if (!grant.CanViewMedicalHistory)
        {
            await TryNotifyPatientAboutAccessRequestAsync(query, appointment, doctorLabel, appointmentDateTime, ct);
            throw new UnauthorizedAccessException("No medical history permission");
        }

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

        await _notificationService.NotifyAsync(new NotificationDispatchRequest
        {
            UserId = query.PatientId,
            Title = "Medical History Viewed",
            Message = appointmentDateTime == null
                ? $"{doctorLabel} viewed your medical history for appointment #{query.AppointmentId}."
                : $"{doctorLabel} viewed your medical history for your appointment on {appointmentDateTime}.",
            Type = NotificationType.MedicalHistoryViewed,
            RelatedEntityType = "Appointment",
            Data = new Dictionary<string, string>
            {
                ["appointmentId"] = query.AppointmentId.ToString(),
                ["doctorId"] = query.DoctorId.ToString(),
                ["patientId"] = query.PatientId.ToString()
            }
        }, ct);

        return await _profileHandler.HandleAsync(
            new GetCompleteMedicalProfileQuery(query.PatientId));
    }

    private async Task TryNotifyPatientAboutAccessRequestAsync(
        GetPatientMedicalProfileForDoctorQuery query,
        Appointment? appointment,
        string doctorLabel,
        string? appointmentDateTime,
        CancellationToken ct)
    {
        try
        {
            if (appointment == null ||
                appointment.PatientId != query.PatientId ||
                appointment.DoctorId != query.DoctorId ||
                appointment.TimeSlot == null)
            {
                return;
            }

            var appointmentEndUtc = appointment.TimeSlot.SlotDate.Add(appointment.TimeSlot.EndTime);
            var requestWindowEndsUtc = appointmentEndUtc.AddHours(24);
            if (DateTime.UtcNow > requestWindowEndsUtc)
            {
                return;
            }

            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = query.PatientId,
                Title = "Doctor Needs Medical History Access",
                Message = appointmentDateTime == null
                    ? $"{doctorLabel} tried to open your medical history and needs your permission to continue."
                    : $"{doctorLabel} tried to open your medical history for your appointment on {appointmentDateTime} and needs your permission to continue.",
                Type = NotificationType.MedicalHistoryAccessRequested,
                RelatedEntityType = "Appointment",
                Data = new Dictionary<string, string>
                {
                    ["appointmentId"] = query.AppointmentId.ToString(),
                    ["doctorId"] = query.DoctorId.ToString(),
                    ["patientId"] = query.PatientId.ToString(),
                    ["accessWindowEndsAt"] = requestWindowEndsUtc.ToString("O")
                }
            }, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex,
                "Failed to notify patient {PatientId} about medical history access request for appointment {AppointmentId}",
                query.PatientId,
                query.AppointmentId);
        }
    }
}

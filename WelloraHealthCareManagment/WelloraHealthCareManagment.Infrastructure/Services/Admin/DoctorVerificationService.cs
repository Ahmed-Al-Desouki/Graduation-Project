// Infrastructure/Services/DoctorVerificationService.cs
using HealthCare_.Models.DoctorModels;
using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class DoctorVerificationService : IDoctorVerificationService
    {
        private readonly IDoctorVerificationRepository _verificationRepository;
        private readonly IDoctorRepository _doctorRepository;
        private readonly INotificationService _notificationService;
        private readonly IRealtimeService _realtimeService;
        private readonly IAdminAuditService _auditService;
        private readonly IEmailService _emailService;
        private readonly IMapper _mapper;
        private readonly ILogger<DoctorVerificationService> _logger;

        public DoctorVerificationService(
            IDoctorVerificationRepository verificationRepository,
            IDoctorRepository doctorRepository,
            INotificationService notificationService,
            IRealtimeService realtimeService,
            IAdminAuditService auditService,
            IEmailService emailService,
            IMapper mapper,
            ILogger<DoctorVerificationService> logger)
        {
            _verificationRepository = verificationRepository;
            _doctorRepository = doctorRepository;
            _notificationService = notificationService;
            _realtimeService = realtimeService;
            _auditService = auditService;
            _emailService = emailService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<ServiceResult<DoctorVerificationListResponse>> GetPendingVerificationsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            try
            {
                var doctors = await _verificationRepository.GetPendingDoctorsWithVerificationsAsync(page, pageSize, ct);
                var totalCount = await _verificationRepository.CountPendingDoctorsAsync(ct);
                var pendingCount = totalCount;

                var response = new DoctorVerificationListResponse
                {
                    Doctors = MapDoctorVerificationGroups(doctors),
                    TotalCount = totalCount,
                    PendingCount = pendingCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<DoctorVerificationListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting pending verifications");
                return ServiceResult<DoctorVerificationListResponse>.Failure("Failed to get pending verifications");
            }
        }

        public async Task<ServiceResult<DoctorVerificationListResponse>> GetAllVerificationsAsync(
            VerificationStatus? status = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            try
            {
                var doctors = await _verificationRepository.GetDoctorsWithVerificationsAsync(
                    status, fromDate, toDate, page, pageSize, ct);

                var totalCount = await _verificationRepository.CountDoctorsAsync(
                    status, fromDate, toDate, ct);

                var pendingCount = await _verificationRepository.CountPendingDoctorsAsync(ct);

                var response = new DoctorVerificationListResponse
                {
                    Doctors = MapDoctorVerificationGroups(doctors),
                    TotalCount = totalCount,
                    PendingCount = pendingCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<DoctorVerificationListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting all verifications");
                return ServiceResult<DoctorVerificationListResponse>.Failure("Failed to get verifications");
            }
        }

        public async Task<ServiceResult<DoctorVerificationDoctorDto>> GetDoctorVerificationDetailsAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId, ct);
                if (doctor == null)
                    return ServiceResult<DoctorVerificationDoctorDto>.Failure("Doctor not found");

                var verifications = await _verificationRepository.GetByDoctorIdAsync(doctorId, ct);
                if (verifications.Count == 0)
                    return ServiceResult<DoctorVerificationDoctorDto>.Failure("Doctor verification request not found");

                doctor.Verifications = verifications;
                var dto = MapDoctorVerificationGroup(doctor);
                return ServiceResult<DoctorVerificationDoctorDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting verification request details for doctor {DoctorId}", doctorId);
                return ServiceResult<DoctorVerificationDoctorDto>.Failure("Failed to get verification details");
            }
        }

        public async Task<ServiceResult> ApproveDoctorAsync(
            int doctorId,
            ApproveDoctorVerificationRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId, ct);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                var currentVerifications = await _verificationRepository.GetByDoctorIdAsync(doctorId, ct);
                var requestStatus = DoctorVerificationPolicy.DetermineRequestStatus(currentVerifications);
                var missingRequiredDocuments = DoctorVerificationPolicy.GetMissingRequiredDocuments(currentVerifications);

                if (missingRequiredDocuments.Count > 0)
                    return ServiceResult.Failure("Doctor verification request is incomplete and cannot be approved yet");

                if (requestStatus == DoctorVerificationRequestStatus.Rejected)
                    return ServiceResult.Failure("Doctor verification request contains rejected documents that must be replaced first");

                var pendingVerifications = currentVerifications
                    .Where(v => v.Status == VerificationStatus.Pending)
                    .ToList();

                if (pendingVerifications.Count == 0)
                    return ServiceResult.Failure("There are no pending verification documents to approve");

                foreach (var pendingVerification in pendingVerifications)
                {
                    pendingVerification.Status = VerificationStatus.Approved;
                    pendingVerification.ReviewedByAdminId = adminId;
                    pendingVerification.ReviewedAt = DateTime.UtcNow;
                    pendingVerification.AdminNotes = request.AdminNotes;
                    pendingVerification.RejectionReason = null;
                    pendingVerification.UpdatedAt = DateTime.UtcNow;

                    await _verificationRepository.UpdateAsync(pendingVerification, ct);
                }

                // Activate doctor only after the whole request becomes approved
                doctor.IsActive = DoctorVerificationPolicy.IsDoctorEligibleForActivation(await _verificationRepository.GetByDoctorIdAsync(doctorId, ct));
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                // Send notification
                await _notificationService.SendDoctorApprovedNotificationAsync(
                    doctorId,
                    ct);

                await SendDoctorApprovalEmailAsync(doctor, request.AdminNotes);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.ApproveDoctor,
                    "Doctor",
                    doctorId.ToString(),
                    new
                    {
                        ApprovedVerificationIds = pendingVerifications.Select(v => v.VerificationId).ToList(),
                        AdminNotes = request.AdminNotes
                    },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "Admin {AdminId} approved doctor verification request for doctor {DoctorId}",
                    adminId, doctorId);
                await BroadcastVerificationUpdatedAsync(doctorId, doctor.IsActive, "Approved", null, ct);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error approving doctor verification request for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Failed to approve doctor");
            }
        }

        public async Task<ServiceResult> RejectDoctorAsync(
            int doctorId,
            RejectDoctorVerificationRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(doctorId, ct);
                if (doctor == null)
                    return ServiceResult.Failure("Doctor not found");

                var currentVerifications = await _verificationRepository.GetByDoctorIdAsync(doctorId, ct);
                var pendingVerifications = currentVerifications
                    .Where(v => v.Status == VerificationStatus.Pending)
                    .ToList();

                if (pendingVerifications.Count == 0)
                    return ServiceResult.Failure("There are no pending verification documents to reject");

                foreach (var pendingVerification in pendingVerifications)
                {
                    pendingVerification.Status = VerificationStatus.Rejected;
                    pendingVerification.ReviewedByAdminId = adminId;
                    pendingVerification.ReviewedAt = DateTime.UtcNow;
                    pendingVerification.RejectionReason = request.RejectionReason;
                    pendingVerification.AdminNotes = request.AdminNotes;
                    pendingVerification.UpdatedAt = DateTime.UtcNow;

                    await _verificationRepository.UpdateAsync(pendingVerification, ct);
                }

                // Ensure doctor is inactive while the request is rejected
                doctor.IsActive = false;
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                // Send notification with rejection reason
                await _notificationService.SendDoctorRejectedNotificationAsync(
                    doctorId,
                    request.RejectionReason,
                    ct);

                await SendDoctorRejectionEmailAsync(doctor, request.RejectionReason, request.AdminNotes);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.RejectDoctor,
                    "Doctor",
                    doctorId.ToString(),
                    new
                    {
                        RejectedVerificationIds = pendingVerifications.Select(v => v.VerificationId).ToList(),
                        RejectionReason = request.RejectionReason,
                        AdminNotes = request.AdminNotes
                    },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "Admin {AdminId} rejected doctor verification request for doctor {DoctorId}. Reason: {Reason}",
                    adminId, doctorId, request.RejectionReason);
                await BroadcastVerificationUpdatedAsync(
                    doctorId,
                    doctor.IsActive,
                    "Rejected",
                    request.RejectionReason,
                    ct);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rejecting doctor verification request for doctor {DoctorId}", doctorId);
                return ServiceResult.Failure("Failed to reject doctor");
            }
        }

        public async Task<bool> IsDoctorVerifiedAsync(int doctorId, CancellationToken ct = default)
        {
            return await _verificationRepository.IsDoctorVerifiedAsync(doctorId, ct);
        }

        public async Task<ServiceResult<VerificationStatus?>> GetDoctorVerificationStatusAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            try
            {
                var status = await _verificationRepository.GetDoctorVerificationStatusAsync(doctorId, ct);
                return ServiceResult<VerificationStatus?>.Success(status);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting verification status for doctor {DoctorId}", doctorId);
                return ServiceResult<VerificationStatus?>.Failure("Failed to get verification status");
            }
        }

        public async Task<ServiceResult<VerificationStatisticsDto>> GetStatisticsAsync(CancellationToken ct = default)
        {
            try
            {
                var doctors = await _verificationRepository.GetAllDoctorsWithVerificationsAsync(ct);
                var statusCounts = doctors
                    .Select(d => DoctorVerificationPolicy.DetermineRequestStatus(d.Verifications))
                    .GroupBy(status => status)
                    .ToDictionary(group => group.Key, group => group.Count());

                var stats = new VerificationStatisticsDto
                {
                    TotalDoctors = doctors.Count,
                    PendingDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Pending, 0),
                    ApprovedDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Approved, 0),
                    RejectedDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Rejected, 0),
                    IncompleteDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Incomplete, 0),
                    DoctorsByStatus = statusCounts,
                    ApprovedThisMonth = await _verificationRepository.CountApprovedThisMonthAsync(new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1), ct),
                    RejectedThisMonth = await _verificationRepository.CountRejectedThisMonthAsync(new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1), ct)
                };

                return ServiceResult<VerificationStatisticsDto>.Success(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting verification statistics");
                return ServiceResult<VerificationStatisticsDto>.Failure("Failed to get statistics");
            }
        }

        private List<DoctorVerificationDoctorDto> MapDoctorVerificationGroups(IEnumerable<Doctor> doctors)
        {
            return doctors
                .Select(MapDoctorVerificationGroup)
                .ToList();
        }

        private DoctorVerificationDoctorDto MapDoctorVerificationGroup(Doctor doctor)
        {
            var requestStatus = DoctorVerificationPolicy.DetermineRequestStatus(doctor.Verifications);
            var missingRequiredDocuments = DoctorVerificationPolicy.GetMissingRequiredDocuments(doctor.Verifications);
            var latestReviewSnapshot = doctor.Verifications
                .Where(v => v.ReviewedAt.HasValue || !string.IsNullOrWhiteSpace(v.AdminNotes) || !string.IsNullOrWhiteSpace(v.RejectionReason))
                .OrderByDescending(v => v.ReviewedAt ?? DateTime.MinValue)
                .ThenByDescending(v => v.UpdatedAt ?? DateTime.MinValue)
                .ThenByDescending(v => v.VerificationId)
                .FirstOrDefault();

            var requestSubmittedAt = doctor.Verifications.Count == 0
                ? (DateTime?)null
                : doctor.Verifications.Max(v => v.SubmittedAt);

            return new DoctorVerificationDoctorDto
            {
                DoctorId = doctor.DoctorId,
                DoctorName = doctor.User?.FullName ?? string.Empty,
                DoctorEmail = doctor.User?.Email ?? string.Empty,
                PhoneNumber = doctor.User?.PhoneNumber,
                Specialization = doctor.Specialization,
                ClinicLocation = doctor.ClinicAddress,
                YearsOfExperience = doctor.YearsOfExperience,
                RequestStatus = requestStatus,
                IsReadyForReview = missingRequiredDocuments.Count == 0,
                AdminNotes = latestReviewSnapshot?.AdminNotes,
                RejectionReason = latestReviewSnapshot?.RejectionReason,
                ReviewedByAdminId = latestReviewSnapshot?.ReviewedByAdminId,
                ReviewedByAdminName = latestReviewSnapshot?.ReviewedByAdmin?.FullName ?? (latestReviewSnapshot?.ReviewedByAdminId.HasValue == true ? "Admin" : null),
                ReviewedAt = latestReviewSnapshot?.ReviewedAt,
                SubmittedAt = requestSubmittedAt,
                MissingRequiredDocuments = missingRequiredDocuments.ToList(),
                Verifications = doctor.Verifications
                    .OrderByDescending(v => v.SubmittedAt)
                    .ThenByDescending(v => v.VerificationId)
                    .Select(v => new DoctorVerificationFileDto
                    {
                        VerificationId = v.VerificationId,
                        DocumentType = v.DocumentType,
                        FileUrl = v.File?.FileUrl
                    })
                    .ToList()
            };
        }

        private Task BroadcastVerificationUpdatedAsync(
            int doctorId,
            bool isActive,
            string status,
            string? rejectionReason,
            CancellationToken ct)
        {
            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { doctorId },
                "doctorverification",
                doctorId.ToString(),
                "DoctorVerificationUpdated",
                new DoctorVerificationRealtimeDto
                {
                    DoctorId = doctorId,
                    IsActive = isActive,
                    Status = status,
                    RejectionReason = rejectionReason,
                    UpdatedAt = DateTime.UtcNow
                },
                ct);
        }

        private async Task SendDoctorApprovalEmailAsync(Doctor doctor, string? adminNotes)
        {
            var email = doctor.User?.Email;
            if (string.IsNullOrWhiteSpace(email))
            {
                _logger.LogWarning("Skipped doctor approval email because doctor {DoctorId} has no email address", doctor.DoctorId);
                return;
            }

            var sent = await _emailService.SendDoctorVerificationApprovedEmailAsync(
                email,
                doctor.User?.FullName ?? "Doctor",
                adminNotes);

            if (!sent)
            {
                _logger.LogWarning("Failed to send doctor approval email to doctor {DoctorId}", doctor.DoctorId);
            }
        }

        private async Task SendDoctorRejectionEmailAsync(Doctor doctor, string rejectionReason, string? adminNotes)
        {
            var email = doctor.User?.Email;
            if (string.IsNullOrWhiteSpace(email))
            {
                _logger.LogWarning("Skipped doctor rejection email because doctor {DoctorId} has no email address", doctor.DoctorId);
                return;
            }

            var sent = await _emailService.SendDoctorVerificationRejectedEmailAsync(
                email,
                doctor.User?.FullName ?? "Doctor",
                rejectionReason,
                adminNotes);

            if (!sent)
            {
                _logger.LogWarning("Failed to send doctor rejection email to doctor {DoctorId}", doctor.DoctorId);
            }
        }
    }
}

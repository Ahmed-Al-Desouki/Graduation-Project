// Infrastructure/Services/DoctorVerificationService.cs
using HealthCare_.Models.DoctorModels;
using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
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
        private readonly IAdminAuditService _auditService;
        private readonly IMapper _mapper;
        private readonly ILogger<DoctorVerificationService> _logger;

        public DoctorVerificationService(
            IDoctorVerificationRepository verificationRepository,
            IDoctorRepository doctorRepository,
            INotificationService notificationService,
            IAdminAuditService auditService,
            IMapper mapper,
            ILogger<DoctorVerificationService> logger)
        {
            _verificationRepository = verificationRepository;
            _doctorRepository = doctorRepository;
            _notificationService = notificationService;
            _auditService = auditService;
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
                var pendingCount = await _verificationRepository.CountPendingVerificationsAsync(ct);

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

                var pendingCount = await _verificationRepository.CountPendingVerificationsAsync(ct);

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

        public async Task<ServiceResult<DoctorVerificationDto>> GetVerificationDetailsAsync(
            int verificationId,
            CancellationToken ct = default)
        {
            try
            {
                var verification = await _verificationRepository.GetByIdWithDoctorAsync(verificationId, ct);
                if (verification == null)
                    return ServiceResult<DoctorVerificationDto>.Failure("Verification not found");

                var dto = _mapper.Map<DoctorVerificationDto>(verification);
                return ServiceResult<DoctorVerificationDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting verification details {VerificationId}", verificationId);
                return ServiceResult<DoctorVerificationDto>.Failure("Failed to get verification details");
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
                var statusCounts = await _verificationRepository.GetStatusCountsAsync(ct);

                var stats = new VerificationStatisticsDto
                {
                    TotalVerifications = statusCounts.Values.Sum(),
                    PendingVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Pending, 0),
                    ApprovedVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Approved, 0),
                    RejectedVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Rejected, 0),
                    VerificationsByStatus = statusCounts
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
                .Select(doctor => new DoctorVerificationDoctorDto
                {
                    DoctorId = doctor.DoctorId,
                    DoctorName = doctor.User?.FullName ?? string.Empty,
                    DoctorEmail = doctor.User?.Email ?? string.Empty,
                    PhoneNumber = doctor.User?.PhoneNumber,
                    Specialization = doctor.Specialization,
                    ClinicLocation = doctor.ClinicAddress,
                    YearsOfExperience = doctor.YearsOfExperience,
                    RequestStatus = DoctorVerificationPolicy.DetermineRequestStatus(doctor.Verifications),
                    IsReadyForReview = DoctorVerificationPolicy.GetMissingRequiredDocuments(doctor.Verifications).Count == 0,
                    MissingRequiredDocuments = DoctorVerificationPolicy.GetMissingRequiredDocuments(doctor.Verifications).ToList(),
                    Verifications = doctor.Verifications
                        .OrderByDescending(v => v.SubmittedAt)
                        .ThenByDescending(v => v.VerificationId)
                        .Select(v => _mapper.Map<DoctorVerificationDto>(v))
                        .ToList()
                })
                .ToList();
        }
    }
}

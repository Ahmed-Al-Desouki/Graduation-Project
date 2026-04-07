// Infrastructure/Services/DoctorVerificationService.cs
using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;

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
                var verifications = await _verificationRepository.GetPendingVerificationsAsync(page, pageSize, ct);
                var totalCount = await _verificationRepository.CountPendingVerificationsAsync(ct);
                var pendingCount = totalCount;

                var dtos = _mapper.Map<List<DoctorVerificationDto>>(verifications);

                var response = new DoctorVerificationListResponse
                {
                    Verifications = dtos,
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
                var verifications = await _verificationRepository.GetAllAsync(
                    status, fromDate, toDate, page, pageSize, ct);

                var totalCount = await _verificationRepository.CountAllAsync(
                    status, fromDate, toDate, ct);

                var pendingCount = await _verificationRepository.CountPendingVerificationsAsync(ct);

                var dtos = _mapper.Map<List<DoctorVerificationDto>>(verifications);

                var response = new DoctorVerificationListResponse
                {
                    Verifications = dtos,
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
            ApproveDoctorVerificationRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var verification = await _verificationRepository.GetByIdWithDoctorAsync(request.VerificationId, ct);
                if (verification == null)
                    return ServiceResult.Failure("Verification not found");

                if (verification.Status != VerificationStatus.Pending)
                    return ServiceResult.Failure("Verification is not pending");

                // Update verification
                verification.Status = VerificationStatus.Approved;
                verification.ReviewedByAdminId = adminId;
                verification.ReviewedAt = DateTime.UtcNow;
                verification.AdminNotes = request.AdminNotes;
                verification.UpdatedAt = DateTime.UtcNow;

                await _verificationRepository.UpdateAsync(verification, ct);

                // Activate doctor
                var doctor = verification.Doctor;
                doctor.IsActive = true;
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                // Send notification
                await _notificationService.SendDoctorApprovedNotificationAsync(
                    verification.DoctorId,
                    ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.ApproveDoctor,
                    "Doctor",
                    verification.DoctorId.ToString(),
                    new
                    {
                        VerificationId = verification.VerificationId,
                        AdminNotes = request.AdminNotes
                    },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "Admin {AdminId} approved doctor verification {VerificationId} for doctor {DoctorId}",
                    adminId, request.VerificationId, verification.DoctorId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error approving doctor verification {VerificationId}", request.VerificationId);
                return ServiceResult.Failure("Failed to approve doctor");
            }
        }

        public async Task<ServiceResult> RejectDoctorAsync(
            RejectDoctorVerificationRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var verification = await _verificationRepository.GetByIdWithDoctorAsync(request.VerificationId, ct);
                if (verification == null)
                    return ServiceResult.Failure("Verification not found");

                if (verification.Status != VerificationStatus.Pending)
                    return ServiceResult.Failure("Verification is not pending");

                // Update verification (permanent rejection)
                verification.Status = VerificationStatus.Rejected;
                verification.ReviewedByAdminId = adminId;
                verification.ReviewedAt = DateTime.UtcNow;
                verification.RejectionReason = request.RejectionReason;
                verification.AdminNotes = request.AdminNotes;
                verification.UpdatedAt = DateTime.UtcNow;

                await _verificationRepository.UpdateAsync(verification, ct);

                // Ensure doctor is inactive
                var doctor = verification.Doctor;
                doctor.IsActive = false;
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                // Send notification with rejection reason
                await _notificationService.SendDoctorRejectedNotificationAsync(
                    verification.DoctorId,
                    request.RejectionReason,
                    ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.RejectDoctor,
                    "Doctor",
                    verification.DoctorId.ToString(),
                    new
                    {
                        VerificationId = verification.VerificationId,
                        RejectionReason = request.RejectionReason,
                        AdminNotes = request.AdminNotes
                    },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "Admin {AdminId} rejected doctor verification {VerificationId} for doctor {DoctorId}. Reason: {Reason}",
                    adminId, request.VerificationId, verification.DoctorId, request.RejectionReason);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rejecting doctor verification {VerificationId}", request.VerificationId);
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
    }
}
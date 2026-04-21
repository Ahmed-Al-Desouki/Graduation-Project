// Infrastructure/Services/UserManagementService.cs
using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class UserManagementService : IUserManagementService
    {
        private readonly IUserStatusRepository _userStatusRepository;
        private readonly IUserRepository _userRepository;
        private readonly INotificationService _notificationService;
        private readonly IAdminAuditService _auditService;
        private readonly IMapper _mapper;
        private readonly ILogger<UserManagementService> _logger;

        public UserManagementService(
            IUserStatusRepository userStatusRepository,
            IUserRepository userRepository,
            INotificationService notificationService,
            IAdminAuditService auditService,
            IMapper mapper,
            ILogger<UserManagementService> logger)
        {
            _userStatusRepository = userStatusRepository;
            _userRepository = userRepository;
            _notificationService = notificationService;
            _auditService = auditService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<ServiceResult> BlockUserAsync(
            BlockUserRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                // Validate user exists
                var user = await _userRepository.GetByIdAsync(request.UserId);
                if (user == null)
                    return ServiceResult.Failure("User not found");

                // Prevent blocking admins
                if (user.Role == "Admin")
                    return ServiceResult.Failure("Cannot block admin users");

                // Get or create user status
                var userStatus = await _userStatusRepository.GetByUserIdAsync(request.UserId, ct);
                if (userStatus == null)
                {
                    userStatus = new UserStatus
                    {
                        UserId = request.UserId,
                        CreatedAt = DateTime.UtcNow
                    };
                }

                // Check if already blocked
                if (userStatus.IsBlocked)
                    return ServiceResult.Failure("User is already blocked");

                // Block user
                userStatus.IsBlocked = true;
                userStatus.BlockedAt = DateTime.UtcNow;
                userStatus.BlockedByAdminId = adminId;
                userStatus.BlockReason = request.Reason;
                userStatus.UpdatedAt = DateTime.UtcNow;

                if (userStatus.Id == Guid.Empty)
                    await _userStatusRepository.CreateAsync(userStatus, ct);
                else
                    await _userStatusRepository.UpdateAsync(userStatus, ct);

                // Send notification
                await _notificationService.SendAccountBlockedNotificationAsync(
                    request.UserId,
                    request.Reason,
                    ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.BlockUser,
                    "User",
                    request.UserId.ToString(),
                    new { Reason = request.Reason },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "User {UserId} blocked by admin {AdminId}. Reason: {Reason}",
                    request.UserId, adminId, request.Reason);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error blocking user {UserId}", request.UserId);
                return ServiceResult.Failure("Failed to block user");
            }
        }

        public async Task<ServiceResult> UnblockUserAsync(
            UnblockUserRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var userStatus = await _userStatusRepository.GetByUserIdAsync(request.UserId, ct);
                if (userStatus == null || !userStatus.IsBlocked)
                    return ServiceResult.Failure("User is not blocked");

                // Unblock user
                userStatus.IsBlocked = false;
                userStatus.BlockedAt = null;
                userStatus.BlockedByAdminId = null;
                userStatus.BlockReason = null;
                userStatus.UpdatedAt = DateTime.UtcNow;

                await _userStatusRepository.UpdateAsync(userStatus, ct);

                // Send notification
                await _notificationService.SendAccountUnblockedNotificationAsync(request.UserId, ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.UnblockUser,
                    "User",
                    request.UserId.ToString(),
                    null,
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "User {UserId} unblocked by admin {AdminId}",
                    request.UserId, adminId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error unblocking user {UserId}", request.UserId);
                return ServiceResult.Failure("Failed to unblock user");
            }
        }

        public async Task<ServiceResult> SuspendUserAsync(
            SuspendUserRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                // Validate suspension end date
                if (request.SuspensionEndDate <= DateTime.UtcNow)
                    return ServiceResult.Failure("Suspension end date must be in the future");

                var user = await _userRepository.GetByIdAsync(request.UserId);
                if (user == null)
                    return ServiceResult.Failure("User not found");

                // Prevent suspending admins
                if (user.Role == "Admin")
                    return ServiceResult.Failure("Cannot suspend admin users");

                // Get or create user status
                var userStatus = await _userStatusRepository.GetByUserIdAsync(request.UserId, ct);
                if (userStatus == null)
                {
                    userStatus = new UserStatus
                    {
                        UserId = request.UserId,
                        CreatedAt = DateTime.UtcNow
                    };
                }

                // Check if already suspended
                if (userStatus.IsSuspended &&
                    userStatus.SuspensionEndDate.HasValue &&
                    userStatus.SuspensionEndDate.Value > DateTime.UtcNow)
                {
                    return ServiceResult.Failure("User is already suspended");
                }

                // Suspend user
                userStatus.IsSuspended = true;
                userStatus.SuspendedAt = DateTime.UtcNow;
                userStatus.SuspensionEndDate = request.SuspensionEndDate;
                userStatus.SuspendedByAdminId = adminId;
                userStatus.SuspensionReason = request.Reason;
                userStatus.UpdatedAt = DateTime.UtcNow;

                if (userStatus.Id == Guid.Empty)
                    await _userStatusRepository.CreateAsync(userStatus, ct);
                else
                    await _userStatusRepository.UpdateAsync(userStatus, ct);

                // Send notification
                await _notificationService.SendAccountSuspendedNotificationAsync(
                    request.UserId,
                    request.SuspensionEndDate,
                    request.Reason,
                    ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.SuspendUser,
                    "User",
                    request.UserId.ToString(),
                    new
                    {
                        SuspensionEndDate = request.SuspensionEndDate,
                        Reason = request.Reason
                    },
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "User {UserId} suspended by admin {AdminId} until {EndDate}. Reason: {Reason}",
                    request.UserId, adminId, request.SuspensionEndDate, request.Reason);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error suspending user {UserId}", request.UserId);
                return ServiceResult.Failure("Failed to suspend user");
            }
        }

        public async Task<ServiceResult> UnsuspendUserAsync(
            UnsuspendUserRequest request,
            int adminId,
            string? ipAddress = null,
            CancellationToken ct = default)
        {
            try
            {
                var userStatus = await _userStatusRepository.GetByUserIdAsync(request.UserId, ct);
                if (userStatus == null || !userStatus.IsSuspended)
                    return ServiceResult.Failure("User is not suspended");

                // Unsuspend user
                userStatus.IsSuspended = false;
                userStatus.SuspendedAt = null;
                userStatus.SuspensionEndDate = null;
                userStatus.SuspendedByAdminId = null;
                userStatus.SuspensionReason = null;
                userStatus.UpdatedAt = DateTime.UtcNow;

                await _userStatusRepository.UpdateAsync(userStatus, ct);
                await _notificationService.SendAccountUnsuspendedNotificationAsync(request.UserId, ct);

                // Log action
                await _auditService.LogActionAsync(
                    adminId,
                    AdminActionType.UnsuspendUser,
                    "User",
                    request.UserId.ToString(),
                    null,
                    ipAddress,
                    ct: ct);

                _logger.LogInformation(
                    "User {UserId} unsuspended by admin {AdminId}",
                    request.UserId, adminId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error unsuspending user {UserId}", request.UserId);
                return ServiceResult.Failure("Failed to unsuspend user");
            }
        }

        public async Task<ServiceResult<UserStatusDto>> GetUserStatusAsync(
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                var userStatus = await _userStatusRepository.GetByUserIdAsync(userId, ct);
                if (userStatus != null &&
                    userStatus.IsSuspended &&
                    userStatus.SuspensionEndDate.HasValue &&
                    userStatus.SuspensionEndDate.Value <= DateTime.UtcNow)
                {
                    userStatus = await _userStatusRepository.GetEffectiveByUserIdAsync(userId, ct);
                }

                if (userStatus == null)
                {
                    // No status record means user is active
                    var user = await _userRepository.GetByIdAsync(userId);
                    if (user == null)
                        return ServiceResult<UserStatusDto>.Failure("User not found");

                    return ServiceResult<UserStatusDto>.Success(new UserStatusDto
                    {
                        UserId = userId,
                        UserName = user.FullName,
                        Email = user.Email ?? string.Empty,
                        IsBlocked = false,
                        IsSuspended = false
                    });
                }

                var dto = _mapper.Map<UserStatusDto>(userStatus);
                return ServiceResult<UserStatusDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user status for {UserId}", userId);
                return ServiceResult<UserStatusDto>.Failure("Failed to get user status");
            }
        }

        public async Task<bool> IsUserActiveAsync(int userId, CancellationToken ct = default)
        {
            return await _userStatusRepository.IsActiveAsync(userId, ct);
        }

        public async Task<ServiceResult<string>> GetInactiveReasonAsync(
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                var userStatus = await _userStatusRepository.GetByUserIdAsync(userId, ct);
                if (userStatus != null &&
                    userStatus.IsSuspended &&
                    userStatus.SuspensionEndDate.HasValue &&
                    userStatus.SuspensionEndDate.Value <= DateTime.UtcNow)
                {
                    userStatus = await _userStatusRepository.GetEffectiveByUserIdAsync(userId, ct);
                }

                if (userStatus == null)
                    return ServiceResult<string>.Success("Active");

                if (userStatus.IsBlocked)
                    return ServiceResult<string>.Success($"Account blocked: {userStatus.BlockReason}");

                if (userStatus.IsSuspended)
                {
                    if (userStatus.SuspensionEndDate.HasValue &&
                        userStatus.SuspensionEndDate.Value > DateTime.UtcNow)
                    {
                        return ServiceResult<string>.Success(
                            $"Account suspended until {userStatus.SuspensionEndDate.Value:yyyy-MM-dd}: {userStatus.SuspensionReason}");
                    }
                }

                return ServiceResult<string>.Success("Active");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inactive reason for {UserId}", userId);
                return ServiceResult<string>.Failure("Failed to get inactive reason");
            }
        }

        public async Task<ServiceResult<List<UserStatusDto>>> GetBlockedUsersAsync(
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            try
            {
                var blockedUsers = await _userStatusRepository.GetBlockedUsersAsync(page, pageSize, ct);
                var dtos = _mapper.Map<List<UserStatusDto>>(blockedUsers);
                return ServiceResult<List<UserStatusDto>>.Success(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting blocked users");
                return ServiceResult<List<UserStatusDto>>.Failure("Failed to get blocked users");
            }
        }

        public async Task<ServiceResult<List<UserStatusDto>>> GetSuspendedUsersAsync(
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            try
            {
                var suspendedUsers = await _userStatusRepository.GetSuspendedUsersAsync(page, pageSize, ct);
                var dtos = _mapper.Map<List<UserStatusDto>>(suspendedUsers);
                return ServiceResult<List<UserStatusDto>>.Success(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting suspended users");
                return ServiceResult<List<UserStatusDto>>.Failure("Failed to get suspended users");
            }
        }

        public async Task ProcessExpiredSuspensionsAsync(CancellationToken ct = default)
        {
            try
            {
                var expiredUserIds = await _userStatusRepository.GetExpiredSuspensionsAsync(ct);

                if (expiredUserIds.Any())
                {
                    await _userStatusRepository.UnsuspendExpiredAsync(expiredUserIds, ct);
                    _logger.LogInformation(
                        "Auto-unsuspended {Count} users with expired suspensions",
                        expiredUserIds.Count);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing expired suspensions");
            }
        }
    }
}

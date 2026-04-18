// Infrastructure/Services/UserSearchService.cs
using F23.StringSimilarity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.Search;

namespace WelloraHealthCareManagement.Infrastructure.Services;

public class UserSearchService : IUserSearchService
{
    private readonly IUserRepository _userRepository;
    private readonly IUserStatusRepository _userStatusRepository;
    private readonly IDoctorVerificationRepository _verificationRepository;
    private readonly Trie _nameTrie = new();
    private readonly Trie _emailTrie = new();
    private readonly ILogger<UserSearchService> _logger;
    private bool _indexBuilt = false;
    private const double SimilarityThreshold = 0.75;

    public UserSearchService(
        IUserRepository userRepository,
        IUserStatusRepository userStatusRepository,
        IDoctorVerificationRepository verificationRepository,
        ILogger<UserSearchService> logger)
    {
        _userRepository = userRepository;
        _userStatusRepository = userStatusRepository;
        _verificationRepository = verificationRepository;
        _logger = logger;
    }

    public async Task<ServiceResult<UserSearchResponse>> SearchUsersAsync(
        UserSearchRequest request,
        CancellationToken ct = default)
    {
        try
        {
            if (request.Page < 1) request.Page = 1;
            if (request.PageSize < 1 || request.PageSize > 50) request.PageSize = 10;

            if (!_indexBuilt)
                await RebuildIndexAsync(ct);

            List<int> searchMatchUserIds = new();
            string searchType = "Database";

            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                var normalizedSearch = Trie.Normalize(request.SearchTerm);
                var nameMatches = _nameTrie.GetWordsByPrefix(normalizedSearch, 100);
                var emailMatches = _emailTrie.GetWordsByPrefix(normalizedSearch, 100);

                if (nameMatches.Any() || emailMatches.Any())
                {
                    var allMatches = nameMatches.Concat(emailMatches).Distinct().ToList();
                    searchMatchUserIds = await _userRepository.GetUserIdsByNameOrEmailAsync(allMatches, ct);
                    searchType = "Trie";
                }
                else
                {
                    var jaro = new JaroWinkler();
                    var allUsers = await _userRepository.GetAllUsersWithDoctorAsync(ct);

                    var fuzzyMatches = allUsers
                        .Select(u => new
                        {
                            User = u,
                            NameScore = jaro.Similarity(Trie.Normalize(u.FullName), normalizedSearch),
                            EmailScore = u.Email != null ? jaro.Similarity(Trie.Normalize(u.Email), normalizedSearch) : 0
                        })
                        .Where(x => x.NameScore >= SimilarityThreshold || x.EmailScore >= SimilarityThreshold)
                        .Select(x => x.User.Id)
                        .ToList();

                    if (fuzzyMatches.Any())
                    {
                        searchMatchUserIds = fuzzyMatches;
                        searchType = "Fuzzy";
                    }
                    else
                    {
                        return ServiceResult<UserSearchResponse>.Success(new UserSearchResponse
                        {
                            Users = new List<UserSearchDto>(),
                            TotalCount = 0,
                            Page = request.Page,
                            PageSize = request.PageSize,
                            SearchType = "NoMatch"
                        });
                    }
                }
            }

            var users = await _userRepository.SearchUsersFilteredAsync(
                role: request.Role,
                isBlocked: request.IsBlocked,
                isSuspended: request.IsSuspended,
                isVerified: request.IsVerified,
                specialization: request.Specialization,
                minRating: request.MinRating,
                registeredAfter: request.RegisteredAfter,
                registeredBefore: request.RegisteredBefore,
                sortBy: request.SortBy,
                descending: request.Descending,
                page: request.Page,
                pageSize: request.PageSize,
                userIds: searchMatchUserIds.Any() ? searchMatchUserIds : null,
                ct: ct);

            var totalCount = await _userRepository.CountUsersFilteredAsync(
                role: request.Role,
                isBlocked: request.IsBlocked,
                isSuspended: request.IsSuspended,
                isVerified: request.IsVerified,
                specialization: request.Specialization,
                minRating: request.MinRating,
                registeredAfter: request.RegisteredAfter,
                registeredBefore: request.RegisteredBefore,
                userIds: searchMatchUserIds.Any() ? searchMatchUserIds : null,
                ct: ct);

            var userIds = users.Select(u => u.Id).ToList();
            var userStatuses = await _userStatusRepository.GetUserStatusesByUserIdsAsync(userIds, ct);

            var doctorIds = users.Where(u => u.Doctor != null).Select(u => u.Doctor!.DoctorId).ToList();
            var reviewCounts = await _userRepository.GetDoctorReviewCountsAsync(doctorIds, ct);

            var dtos = users.Select(u =>
            {
                var status = userStatuses.GetValueOrDefault(u.Id);
                return new UserSearchDto
                {
                    UserId = u.Id,
                    FullName = u.FullName,
                    Email = u.Email ?? string.Empty,
                    Role = u.Role,
                    IsBlocked = status?.IsBlocked ?? false,
                    IsSuspended = status?.IsSuspended ?? false,
                    CreatedAt = u.CreatedAt,
                    Specialization = u.Doctor?.Specialization,
                    AverageRating = u.Doctor?.AverageRating,
                    ReviewCount = u.Doctor != null ? reviewCounts.GetValueOrDefault(u.Doctor.DoctorId, 0) : null,
                    IsVerified = u.Doctor?.IsActive
                };
            }).ToList();

            var response = new UserSearchResponse
            {
                Users = dtos,
                TotalCount = totalCount,
                Page = request.Page,
                PageSize = request.PageSize,
                SearchType = searchType,
                IsSuccess = true
            };

            return ServiceResult<UserSearchResponse>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching users");
            return ServiceResult<UserSearchResponse>.Failure("Failed to search users");
        }
    }

    public async Task<ServiceResult<UserSearchDto>> GetUserDetailsAsync(int userId, CancellationToken ct = default)
    {
        try
        {
            var user = await _userRepository.GetByIdWithDoctorAsync(userId, ct);
            if (user == null)
                return ServiceResult<UserSearchDto>.Failure("User not found");

            var status = await _userStatusRepository.GetByUserIdAsync(userId, ct);

            int? reviewCount = null;
            if (user.Doctor != null)
            {
                reviewCount = await _userRepository.GetDoctorReviewCountAsync(user.Doctor.DoctorId, ct);
            }

            var dto = new UserSearchDto
            {
                UserId = user.Id,
                FullName = user.FullName,
                Email = user.Email ?? string.Empty,
                Role = user.Role,
                IsBlocked = status?.IsBlocked ?? false,
                IsSuspended = status?.IsSuspended ?? false,
                CreatedAt = user.CreatedAt,
                Specialization = user.Doctor?.Specialization,
                AverageRating = user.Doctor?.AverageRating,
                ReviewCount = reviewCount,
                IsVerified = user.Doctor?.IsActive
            };

            return ServiceResult<UserSearchDto>.Success(dto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user details {UserId}", userId);
            return ServiceResult<UserSearchDto>.Failure("Failed to get user details");
        }
    }

    public async Task RebuildIndexAsync(CancellationToken ct = default)
    {
        try
        {
            _logger.LogInformation("Building user search index...");
            var users = await _userRepository.GetAllUsersWithDoctorAsync(ct);

            var names = users.Select(u => u.FullName).Distinct();
            var emails = users.Where(u => u.Email != null).Select(u => u.Email!).Distinct();

            foreach (var name in names)
                _nameTrie.Insert(name);

            foreach (var email in emails)
                _emailTrie.Insert(email);

            _indexBuilt = true;

            _logger.LogInformation("User search index built: {NameCount} names, {EmailCount} emails",
                names.Count(), emails.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error rebuilding user search index");
        }
    }

    public async Task<ServiceResult<AllUsersResponse>> GetAllUsersAsync(
        AllUsersRequest request,
        CancellationToken ct = default)
    {
        try
        {
            if (request.DoctorsPage < 1) request.DoctorsPage = 1;
            if (request.DoctorsPageSize < 1 || request.DoctorsPageSize > 50) request.DoctorsPageSize = 10;
            if (request.PatientsPage < 1) request.PatientsPage = 1;
            if (request.PatientsPageSize < 1 || request.PatientsPageSize > 50) request.PatientsPageSize = 10;

            var response = new AllUsersResponse();

            // 1. DOCTORS
            var totalDoctors = await _userRepository.CountDoctorsFilteredAsync(
                request.SearchTerm, request.OnlyVerifiedDoctors, request.OnlyActive, ct);

            var doctors = await _userRepository.GetDoctorsFilteredAsync(
                request.SearchTerm, request.OnlyVerifiedDoctors, request.OnlyActive,
                request.DoctorsPage, request.DoctorsPageSize, ct);

            var doctorUserIds = doctors.Select(u => u.Id).ToList();
            var doctorStatuses = await _userRepository.GetUserStatusesByUserIdsAsync(doctorUserIds, ct);

            var doctorIds = doctors.Where(u => u.Doctor != null).Select(u => u.Doctor!.DoctorId).ToList();
            var reviewCounts = await _userRepository.GetDoctorReviewCountsAsync(doctorIds, ct);

            response.Doctors.Data = doctors.Where(u => u.Doctor != null).Select(u =>
            {
                var status = doctorStatuses.GetValueOrDefault(u.Id);
                var reviewCount = u.Doctor != null ? reviewCounts.GetValueOrDefault(u.Doctor.DoctorId, 0) : 0;
                return new DoctorUserDto
                {
                    UserId = u.Id,
                    DoctorId = u.Doctor?.DoctorId ?? 0,
                    FullName = u.FullName,
                    Email = u.Email ?? string.Empty,
                    PhoneNumber = u.PhoneNumber,
                    Specialization = u.Doctor?.Specialization ?? string.Empty,
                    AverageRating = u.Doctor?.AverageRating,
                    ReviewCount = reviewCount,
                    IsVerified = u.Doctor?.IsActive ?? false,
                    IsBlocked = status?.IsBlocked ?? false,
                    IsSuspended = status?.IsSuspended ?? false,
                    CreatedAt = u.CreatedAt
                };
            }).ToList();

            response.Doctors.TotalCount = totalDoctors;
            response.Doctors.Page = request.DoctorsPage;
            response.Doctors.PageSize = request.DoctorsPageSize;
            response.Doctors.HasNextPage = (request.DoctorsPage * request.DoctorsPageSize) < totalDoctors;

            // 2. PATIENTS
            var totalPatients = await _userRepository.CountPatientsFilteredAsync(
                request.SearchTerm, request.OnlyActive, ct);

            var patients = await _userRepository.GetPatientsFilteredAsync(
                request.SearchTerm, request.OnlyActive,
                request.PatientsPage, request.PatientsPageSize, ct);

            var patientUserIds = patients.Select(u => u.Id).ToList();
            var patientStatuses = await _userRepository.GetUserStatusesByUserIdsAsync(patientUserIds, ct);

            response.Patients.Data = patients
             .Where(u => u.Patient != null)  // ← أضيف السطر ده
             .Select(u =>
             {
                 var status = patientStatuses.GetValueOrDefault(u.Id);
                 return new PatientUserDto
                 {
                     UserId = u.Id,
                     PatientId = u.Patient!.PatientID,
                     FullName = u.FullName,
                     Email = u.Email ?? string.Empty,
                     PhoneNumber = u.PhoneNumber,
                     //BloodType = u.Patient.MedicalHistory?.BloodType,
                     IsBlocked = status?.IsBlocked ?? false,
                     IsSuspended = status?.IsSuspended ?? false,
                     CreatedAt = u.CreatedAt
                 };
             }).ToList();

            response.Patients.TotalCount = totalPatients;
            response.Patients.Page = request.PatientsPage;
            response.Patients.PageSize = request.PatientsPageSize;
            response.Patients.HasNextPage = (request.PatientsPage * request.PatientsPageSize) < totalPatients;

            // 3. TOTAL
            response.TotalUsers = totalDoctors + totalPatients;

            return ServiceResult<AllUsersResponse>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all users");
            return ServiceResult<AllUsersResponse>.Failure("Failed to get all users");
        }
    }
}
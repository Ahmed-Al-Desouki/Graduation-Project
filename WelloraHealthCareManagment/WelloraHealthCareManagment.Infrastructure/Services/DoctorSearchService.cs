// Infrastructure/Services/DoctorSearchService.cs
using F23.StringSimilarity;
using HealthCare_.Models.DoctorModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.DTOs.Search;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories.Search;
using WelloraHealthCareManagment.Application.Interfaces.Search;
using WelloraHealthCareManagment.Domain.Entities.Search;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class DoctorSearchService : IDoctorSearchService
    {
        private readonly IDoctorSearchRepository _searchRepository;
        private readonly IDoctorSearchIndex _searchIndex;
        private readonly ILogger<DoctorSearchService> _logger;
        private const double SimilarityThreshold = 0.75;
        private bool _indexBuilt = false;

        public DoctorSearchService(
            IDoctorSearchRepository searchRepository,
            IDoctorSearchIndex searchIndex,
            ILogger<DoctorSearchService> logger)
        {
            _searchRepository = searchRepository;
            _searchIndex = searchIndex;
            _logger = logger;
        }

        //public async Task<DoctorSearchResponse> SearchAsync(
        //    string query,
        //    string? specialization = null,
        //    int page = 1,
        //    int pageSize = 10,
        //    CancellationToken ct = default)
        //{
        //    if (string.IsNullOrWhiteSpace(query) || query.Length < 2)
        //        return new DoctorSearchResponse();

        //    // Build index if not built yet
        //    if (!_indexBuilt)
        //        await RebuildIndexAsync(ct);

        //    var normalizedQuery = Trie.Normalize(query);
        //    var jaro = new JaroWinkler();

        //    // 1. جرب Prefix Search الأول
        //    var prefixMatches = _searchIndex.SearchNamesByPrefix(normalizedQuery, pageSize * 3);

        //    // لو في تخصص محدد، فلتر الـ specialization index كمان
        //    if (!string.IsNullOrWhiteSpace(specialization))
        //    {
        //        var specMatches = _searchIndex
        //            .SearchSpecializationsByPrefix(Trie.Normalize(specialization), 20);
        //        // لو مفيش نتايج في الـ specialization، رجع empty
        //        if (!specMatches.Any())
        //            return new DoctorSearchResponse();
        //    }

        //    if (prefixMatches.Any())
        //    {
        //        _logger.LogInformation(
        //            "Prefix search found {Count} matches for '{Query}'",
        //            prefixMatches.Count, query);

        //        var doctors = await _searchRepository.GetByNamesAsync(
        //            prefixMatches, specialization, page, pageSize, ct);

        //        var totalCount = await _searchRepository.CountByNamesAsync(
        //            prefixMatches, specialization, ct);

        //        return new DoctorSearchResponse
        //        {
        //            Doctors = doctors.Select(MapToDto).ToList(),
        //            TotalCount = totalCount,
        //            Page = page,
        //            PageSize = pageSize,
        //            SearchType = "Prefix"
        //        };
        //    }

        //    // 2. لو مش لاقي بالـ prefix، جرب Fuzzy Search
        //    _logger.LogInformation(
        //        "No prefix matches, trying fuzzy search for '{Query}'", query);

        //    var allDoctors = await _searchRepository.GetAllActiveAsync(ct);

        //    var fuzzyMatches = allDoctors
        //        .Where(d => !string.IsNullOrWhiteSpace(d.User?.FullName))
        //        .Select(d => new
        //        {
        //            Doctor = d,
        //            Score = jaro.Similarity(
        //                Trie.Normalize(d.User.FullName),
        //                normalizedQuery)
        //        })
        //        .Where(x => x.Score >= SimilarityThreshold)
        //        .Where(d => string.IsNullOrWhiteSpace(specialization) ||
        //            Trie.Normalize(d.Doctor.Specialization) == Trie.Normalize(specialization))
        //        .OrderByDescending(x => x.Score)
        //        .ToList();

        //    var pagedFuzzy = fuzzyMatches
        //        .Skip((page - 1) * pageSize)
        //        .Take(pageSize)
        //        .Select(x => x.Doctor)
        //        .ToList();

        //    return new DoctorSearchResponse
        //    {
        //        Doctors = pagedFuzzy.Select(MapToDto).ToList(),
        //        TotalCount = fuzzyMatches.Count,
        //        Page = page,
        //        PageSize = pageSize,
        //        SearchType = "Fuzzy"
        //    };
        //}

        public async Task<DoctorSearchResponse> SearchAsync(
            string? query,
            string? specialization = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(query) && string.IsNullOrWhiteSpace(specialization))
                return DoctorSearchResponse.Fail("Provide at least a name query or a specialization.");

            if (!string.IsNullOrWhiteSpace(query) && query.Trim().Length < 2)
                return DoctorSearchResponse.Fail("Name query must be at least 2 characters.");

            if (!string.IsNullOrWhiteSpace(specialization) && specialization.Trim().Length < 2)
                return DoctorSearchResponse.Fail("Specialization must be at least 2 characters.");

            if (page < 1) page = 1;
            if (pageSize < 1 || pageSize > 50) pageSize = 10;

            if (!_indexBuilt)
                await RebuildIndexAsync(ct);

            // Resolve specialization: Prefix → Fuzzy → null
            string? resolvedSpecialization = await ResolveSpecializationAsync(specialization);

            // لو بعت تخصص بس ملقاهوش خالص
            if (!string.IsNullOrWhiteSpace(specialization) && resolvedSpecialization == null)
                return new DoctorSearchResponse { IsSuccess = true, Page = page, PageSize = pageSize };

            // Specialization only (no name query)
            if (string.IsNullOrWhiteSpace(query))
            {
                var doctors = await _searchRepository
                    .GetBySpecializationAsync(resolvedSpecialization!, page, pageSize, ct);
                var total = await _searchRepository
                    .CountBySpecializationAsync(resolvedSpecialization!, ct);
                var doctorIds = doctors.Select(d => d.DoctorId).ToList();
                var reviewCounts = await _searchRepository
                    .GetReviewCountsByDoctorIdsAsync(doctorIds, ct);
                return new DoctorSearchResponse
                {
                    Doctors = doctors.Select(d => MapToDto(d, reviewCounts)).ToList(),
                    TotalCount = total,
                    Page = page,
                    PageSize = pageSize,
                    SearchType = "Specialization",
                    IsSuccess = true
                };
            }

            // Name search (with optional specialization filter)
            var normalizedQuery = Trie.Normalize(query);
            var prefixMatches = _searchIndex.SearchNamesByPrefix(normalizedQuery, pageSize * 3);

            if (prefixMatches.Any())
            {
                var doctors = await _searchRepository
                    .GetByNamesAsync(prefixMatches, resolvedSpecialization, page, pageSize, ct);
                var total = await _searchRepository
                    .CountByNamesAsync(prefixMatches, resolvedSpecialization, ct);
                var doctorIds = doctors.Select(d => d.DoctorId).ToList();
                var reviewCounts = await _searchRepository
                    .GetReviewCountsByDoctorIdsAsync(doctorIds, ct);
                return new DoctorSearchResponse
                {
                    Doctors = doctors.Select(d => MapToDto(d, reviewCounts)).ToList(),
                    TotalCount = total,
                    Page = page,
                    PageSize = pageSize,
                    SearchType = "Prefix",
                    IsSuccess = true
                };
            }

            // Fuzzy fallback on name
            var jaro = new JaroWinkler();
            var allDoctors = await _searchRepository.GetAllActiveAsync(ct);

            var fuzzyMatches = allDoctors
                .Where(d => !string.IsNullOrWhiteSpace(d.User?.FullName))
                .Where(d => resolvedSpecialization == null ||
                    Trie.Normalize(d.Specialization) == Trie.Normalize(resolvedSpecialization))
                .Select(d => new
                {
                    Doctor = d,
                    Score = jaro.Similarity(Trie.Normalize(d.User.FullName), normalizedQuery)
                })
                .Where(x => x.Score >= SimilarityThreshold)
                .OrderByDescending(x => x.Score)
                .ToList();

            return new DoctorSearchResponse
            {
                Doctors = fuzzyMatches
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => MapToDto(x.Doctor))
                    .ToList(),
                TotalCount = fuzzyMatches.Count,
                Page = page,
                PageSize = pageSize,
                SearchType = "Fuzzy",
                IsSuccess = true
            };
        }

        private async Task<string?> ResolveSpecializationAsync(string? specialization)
        {
            if (string.IsNullOrWhiteSpace(specialization))
                return null;

            var normalizedSpec = Trie.Normalize(specialization);

            // 1. جرب Prefix في الـ Trie
            var prefixMatches = _searchIndex
                .SearchSpecializationsByPrefix(normalizedSpec, 1);

            if (prefixMatches.Any())
                return prefixMatches.First();

            // 2. Fuzzy fallback على التخصصات
            var jaro = new JaroWinkler();
            var allSpecs = await _searchRepository.GetAllSpecializationsAsync();

            var best = allSpecs
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => new
                {
                    Spec = s,
                    Score = jaro.Similarity(Trie.Normalize(s), normalizedSpec)
                })
                .Where(x => x.Score >= SimilarityThreshold)
                .OrderByDescending(x => x.Score)
                .FirstOrDefault();

            return best?.Spec;
        }

        public async Task RebuildIndexAsync(CancellationToken ct = default)
        {
            _logger.LogInformation("Building doctor search index...");

            var doctors = await _searchRepository.GetAllActiveAsync(ct);
            var specializations = await _searchRepository.GetAllSpecializationsAsync(ct);

            var names = doctors
                .Where(d => d.User?.FullName != null)
                .Select(d => d.User.FullName)
                .Distinct();

            _searchIndex.BuildNameIndex(names);
            _searchIndex.BuildSpecializationIndex(specializations);

            _indexBuilt = true;

            _logger.LogInformation(
                "Search index built: {NameCount} names, {SpecCount} specializations",
                names.Count(), specializations.Count);
        }

        private static DoctorSearchResult MapToDto(HealthCare_.Models.DoctorModels.Doctor d, Dictionary<int, int>? reviewCounts = null)
        {
            var profileImage = d.Files?
                .FirstOrDefault(f => f.CategoryValue == "Profile" && f.DoctorID != null);

            return new DoctorSearchResult
            {
                DoctorId = d.DoctorId,
                FullName = d.User?.FullName ?? string.Empty,
                Specialization = d.Specialization,
                ConsultationFee = d.ConsultationFee,
                AverageRating = d.AverageRating,
                TotalReviews = reviewCounts?.GetValueOrDefault(d.DoctorId, 0) ?? 0,
                YearsOfExperience = d.YearsOfExperience,
                Description = d.Description,
                ProfileImageUrl = profileImage?.FileUrl,
                IsActive = d.IsActive
            };
        }

        public async Task<SpecializationListResponse> GetAllSpecializationsAsync(
            CancellationToken ct = default)
        {
            var specs = await _searchRepository.GetDistinctSpecializationsAsync(ct);
            return new SpecializationListResponse
            {
                Specializations = specs,
                TotalCount = specs.Count
            };
        }

        public async Task<TopRatedDoctorsResponse> GetTopRatedDoctorsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            if (page < 1) page = 1;
            if (pageSize < 1 || pageSize > 50) pageSize = 10;

            var doctors = await _searchRepository.GetTopRatedDoctorsAsync(page, pageSize, ct);
            var total = await _searchRepository.CountTopRatedDoctorsAsync(ct);

            // جيب عدد الـ reviews لكل دكتور
            var doctorIds = doctors.Select(d => d.DoctorId).ToList();
            var reviewCounts = await _searchRepository
                .GetReviewCountsByDoctorIdsAsync(doctorIds, ct);

            return new TopRatedDoctorsResponse
            {
                Doctors = doctors.Select(d => new TopRatedDoctorDto
                {
                    DoctorId = d.DoctorId,
                    FullName = d.User?.FullName ?? string.Empty,
                    Specialization = d.Specialization,
                    ConsultationFee = d.ConsultationFee,
                    AverageRating = d.AverageRating,
                    TotalReviews = reviewCounts.GetValueOrDefault(d.DoctorId, 0),
                    YearsOfExperience = d.YearsOfExperience,
                    Description = d.Description,
                    ProfileImageUrl = d.Files?
                        .FirstOrDefault(f => f.CategoryValue == "Profile" && f.DoctorID != null)
                        ?.FileUrl
                }).ToList(),
                TotalCount = total,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<TopRatedDoctorsResponse> GetAllDoctorsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            if (page < 1) page = 1;
            if (pageSize < 1 || pageSize > 50) pageSize = 10;

            var doctors = await _searchRepository.GetAllDoctorsPagedAsync(page, pageSize, ct);
            var total = await _searchRepository.CountAllDoctorsAsync(ct);

            var doctorIds = doctors.Select(d => d.DoctorId).ToList();
            var reviewCounts = await _searchRepository
                .GetReviewCountsByDoctorIdsAsync(doctorIds, ct);

            return new TopRatedDoctorsResponse
            {
                Doctors = doctors.Select(d => new TopRatedDoctorDto
                {
                    DoctorId = d.DoctorId,
                    FullName = d.User?.FullName ?? string.Empty,
                    Specialization = d.Specialization,
                    ConsultationFee = d.ConsultationFee,
                    AverageRating = d.AverageRating,
                    TotalReviews = reviewCounts.GetValueOrDefault(d.DoctorId, 0),
                    YearsOfExperience = d.YearsOfExperience,
                    Description = d.Description,
                    ProfileImageUrl = d.Files?
                        .FirstOrDefault(f => f.CategoryValue == "Profile" && f.DoctorID != null)
                        ?.FileUrl
                }).ToList(),
                TotalCount = total,
                Page = page,
                PageSize = pageSize
            };
        }
    }
}
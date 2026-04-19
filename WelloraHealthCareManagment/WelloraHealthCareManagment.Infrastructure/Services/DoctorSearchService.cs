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

        public async Task<NearbyDoctorSearchResponse> SearchNearbyAsync(
            double patientLatitude,
            double patientLongitude,
            string? query = null,
            string? specialization = null,
            double? radiusKm = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            if (patientLatitude < -90 || patientLatitude > 90)
                return NearbyDoctorSearchResponse.Fail("Patient latitude must be between -90 and 90.");

            if (patientLongitude < -180 || patientLongitude > 180)
                return NearbyDoctorSearchResponse.Fail("Patient longitude must be between -180 and 180.");

            if (!string.IsNullOrWhiteSpace(query) && query.Trim().Length < 2)
                return NearbyDoctorSearchResponse.Fail("Name query must be at least 2 characters.");

            if (!string.IsNullOrWhiteSpace(specialization) && specialization.Trim().Length < 2)
                return NearbyDoctorSearchResponse.Fail("Specialization must be at least 2 characters.");

            if (radiusKm.HasValue && radiusKm <= 0)
                return NearbyDoctorSearchResponse.Fail("Radius must be greater than 0.");

            if (page < 1) page = 1;
            if (pageSize < 1 || pageSize > 50) pageSize = 10;

            if (!_indexBuilt)
                await RebuildIndexAsync(ct);

            string? resolvedSpecialization = await ResolveSpecializationAsync(specialization);
            if (!string.IsNullOrWhiteSpace(specialization) && resolvedSpecialization == null)
            {
                return new NearbyDoctorSearchResponse
                {
                    IsSuccess = true,
                    Page = page,
                    PageSize = pageSize,
                    PatientLatitude = patientLatitude,
                    PatientLongitude = patientLongitude,
                    RadiusKm = radiusKm
                };
            }

            var candidates = await _searchRepository.GetAllActiveWithLocationAsync(ct);

            if (!string.IsNullOrWhiteSpace(resolvedSpecialization))
            {
                candidates = candidates
                    .Where(d => Trie.Normalize(d.Specialization) == Trie.Normalize(resolvedSpecialization))
                    .ToList();
            }

            var searchType = "NearbyDistance";

            if (!string.IsNullOrWhiteSpace(query))
            {
                var normalizedQuery = Trie.Normalize(query);
                var prefixMatches = _searchIndex.SearchNamesByPrefix(normalizedQuery, 200);
                var normalizedPrefixMatches = prefixMatches
                    .Select(Trie.Normalize)
                    .ToHashSet();

                if (normalizedPrefixMatches.Count > 0)
                {
                    candidates = candidates
                        .Where(d => !string.IsNullOrWhiteSpace(d.User?.FullName) &&
                                    normalizedPrefixMatches.Contains(Trie.Normalize(d.User.FullName)))
                        .ToList();
                    searchType = "NearbyPrefix";
                }
                else
                {
                    var jaro = new JaroWinkler();
                    candidates = candidates
                        .Where(d => !string.IsNullOrWhiteSpace(d.User?.FullName))
                        .Select(d => new
                        {
                            Doctor = d,
                            Score = jaro.Similarity(Trie.Normalize(d.User!.FullName), normalizedQuery)
                        })
                        .Where(x => x.Score >= SimilarityThreshold)
                        .OrderByDescending(x => x.Score)
                        .Select(x => x.Doctor)
                        .ToList();
                    searchType = "NearbyFuzzy";
                }
            }

            var locatedDoctors = candidates
                .Where(d => d.ClinicLatitude.HasValue && d.ClinicLongitude.HasValue)
                .Select(d => new
                {
                    Doctor = d,
                    DistanceKm = CalculateDistanceKm(
                        patientLatitude,
                        patientLongitude,
                        d.ClinicLatitude!.Value,
                        d.ClinicLongitude!.Value)
                });

            if (radiusKm.HasValue)
            {
                locatedDoctors = locatedDoctors
                    .Where(x => x.DistanceKm <= radiusKm.Value);
            }

            var orderedDoctors = locatedDoctors
                .OrderBy(x => x.DistanceKm)
                .ThenByDescending(x => x.Doctor.AverageRating)
                .ThenByDescending(x => x.Doctor.YearsOfExperience)
                .ToList();

            var totalCount = orderedDoctors.Count;
            var pagedDoctors = orderedDoctors
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            var doctorIds = pagedDoctors.Select(x => x.Doctor.DoctorId).ToList();
            var reviewCounts = await _searchRepository.GetReviewCountsByDoctorIdsAsync(doctorIds, ct);

            return new NearbyDoctorSearchResponse
            {
                Doctors = pagedDoctors
                    .Select(x => MapToDto(
                        x.Doctor,
                        reviewCounts,
                        x.DistanceKm,
                        patientLatitude,
                        patientLongitude))
                    .ToList(),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                SearchType = searchType,
                IsSuccess = true,
                PatientLatitude = patientLatitude,
                PatientLongitude = patientLongitude,
                RadiusKm = radiusKm
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
                Bio = d.Bio,
                ProfileImageUrl = profileImage?.FileUrl,
                IsActive = d.IsActive,
                ClinicAddress = d.ClinicAddress,
                ClinicLatitude = d.ClinicLatitude,
                ClinicLongitude = d.ClinicLongitude,
                HospitalName = d.HospitalName,
                ClinicMapUrl = BuildClinicMapUrl(d.ClinicLatitude, d.ClinicLongitude)
            };
        }

        private static DoctorSearchResult MapToDto(
            Doctor d,
            Dictionary<int, int>? reviewCounts,
            double distanceKm,
            double patientLatitude,
            double patientLongitude)
        {
            var dto = MapToDto(d, reviewCounts);
            dto.DistanceKm = Math.Round(distanceKm, 2);
            dto.DirectionsMapUrl = BuildDirectionsMapUrl(
                patientLatitude,
                patientLongitude,
                d.ClinicLatitude,
                d.ClinicLongitude);

            return dto;
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
                    Bio = d.Bio,
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
                    Bio = d.Bio,
                    ProfileImageUrl = d.Files?
                        .FirstOrDefault(f => f.CategoryValue == "Profile" && f.DoctorID != null)
                        ?.FileUrl
                }).ToList(),
                TotalCount = total,
                Page = page,
                PageSize = pageSize
            };
        }

        private static double CalculateDistanceKm(
            double sourceLatitude,
            double sourceLongitude,
            double destinationLatitude,
            double destinationLongitude)
        {
            const double EarthRadiusKm = 6371.0;

            var latitudeDelta = DegreesToRadians(destinationLatitude - sourceLatitude);
            var longitudeDelta = DegreesToRadians(destinationLongitude - sourceLongitude);

            var sourceLatitudeRadians = DegreesToRadians(sourceLatitude);
            var destinationLatitudeRadians = DegreesToRadians(destinationLatitude);

            var haversine =
                Math.Sin(latitudeDelta / 2) * Math.Sin(latitudeDelta / 2) +
                Math.Cos(sourceLatitudeRadians) * Math.Cos(destinationLatitudeRadians) *
                Math.Sin(longitudeDelta / 2) * Math.Sin(longitudeDelta / 2);

            var angularDistance = 2 * Math.Atan2(Math.Sqrt(haversine), Math.Sqrt(1 - haversine));
            return EarthRadiusKm * angularDistance;
        }

        private static double DegreesToRadians(double degrees) => degrees * (Math.PI / 180d);

        private static string? BuildClinicMapUrl(double? clinicLatitude, double? clinicLongitude)
        {
            if (!clinicLatitude.HasValue || !clinicLongitude.HasValue)
                return null;

            return $"https://www.openstreetmap.org/?mlat={clinicLatitude.Value}&mlon={clinicLongitude.Value}#map=16/{clinicLatitude.Value}/{clinicLongitude.Value}";
        }

        private static string? BuildDirectionsMapUrl(
            double patientLatitude,
            double patientLongitude,
            double? clinicLatitude,
            double? clinicLongitude)
        {
            if (!clinicLatitude.HasValue || !clinicLongitude.HasValue)
                return null;

            return $"https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route={patientLatitude}%2C{patientLongitude}%3B{clinicLatitude.Value}%2C{clinicLongitude.Value}";
        }
    }
}

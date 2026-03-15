using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.DTOs.Search;

namespace WelloraHealthCareManagment.Application.Interfaces.Search
{
    public interface IDoctorSearchService
    {
        Task<DoctorSearchResponse> SearchAsync(
            string? query,
            string? specialization = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task RebuildIndexAsync(CancellationToken ct = default);
        Task<SpecializationListResponse> GetAllSpecializationsAsync(CancellationToken ct = default);

        Task<TopRatedDoctorsResponse> GetTopRatedDoctorsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task<TopRatedDoctorsResponse> GetAllDoctorsAsync(
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);
    }
}

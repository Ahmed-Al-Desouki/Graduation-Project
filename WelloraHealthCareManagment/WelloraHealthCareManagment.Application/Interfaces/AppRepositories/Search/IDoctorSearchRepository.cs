using HealthCare_.Models.DoctorModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories.Search
{
    public interface IDoctorSearchRepository
    {
        Task<List<Doctor>> GetByNamesAsync(
            List<string> names,
            string? specialization = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default);

        Task<List<Doctor>> GetAllActiveAsync(CancellationToken ct = default);

        Task<int> CountByNamesAsync(
            List<string> names,
            string? specialization = null,
            CancellationToken ct = default);

        Task<List<string>> GetAllSpecializationsAsync(CancellationToken ct = default);

        Task<List<Doctor>> GetBySpecializationAsync(
            string specialization,
            int page,
            int pageSize,
            CancellationToken ct = default);

        Task<int> CountBySpecializationAsync(
            string specialization,
            CancellationToken ct = default);

        Task<List<string>> GetDistinctSpecializationsAsync(CancellationToken ct = default);

        Task<List<Doctor>> GetTopRatedDoctorsAsync(
            int page,
            int pageSize,
            CancellationToken ct = default);

        Task<int> CountTopRatedDoctorsAsync(CancellationToken ct = default);

        Task<List<Doctor>> GetAllDoctorsPagedAsync(
            int page,
            int pageSize,
            CancellationToken ct = default);

        Task<int> CountAllDoctorsAsync(CancellationToken ct = default);
        Task<Dictionary<int, int>> GetReviewCountsByDoctorIdsAsync(
            List<int> doctorIds,
            CancellationToken ct = default);
    }
}

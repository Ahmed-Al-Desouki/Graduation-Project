using CloudinaryDotNet;
using HealthCare_.Models.DoctorModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories.Search;
using WelloraHealthCareManagment.Domain.Constants;
using WelloraHealthCareManagment.Domain.Entities.Search;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Search
{
    public class DoctorSearchRepository : IDoctorSearchRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorSearchRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<Doctor>> GetByNamesAsync(
            List<string> names,
            string? specialization = null,
            int page = 1,
            int pageSize = 10,
            CancellationToken ct = default)
        {
            var normalizedNames = names.Select(Trie.Normalize).ToList();

            var query = _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Include(d => d.Files)
                .Where(d => d.IsActive &&
                    normalizedNames.Contains(d.User.FullName.ToLower()));

            if (!string.IsNullOrWhiteSpace(specialization))
                query = query.Where(d =>
                    d.Specialization.ToLower() == specialization.ToLower());

            return await query
                .OrderByDescending(d => d.AverageRating)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(ct);
        }

        public async Task<List<Doctor>> GetAllActiveAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Include(d => d.Files)
                .Where(d => d.IsActive)
                .ToListAsync(ct);
        }

        public async Task<int> CountByNamesAsync(
            List<string> names,
            string? specialization = null,
            CancellationToken ct = default)
        {
            var normalizedNames = names.Select(Trie.Normalize).ToList();

            var query = _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Where(d => d.IsActive &&
                    normalizedNames.Contains(d.User.FullName.ToLower()));

            if (!string.IsNullOrWhiteSpace(specialization))
                query = query.Where(d =>
                    d.Specialization.ToLower() == specialization.ToLower());

            return await query.CountAsync(ct);
        }

        public async Task<List<string>> GetAllSpecializationsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Where(d => d.IsActive)
                .Select(d => d.Specialization)
                .Distinct()
                .ToListAsync(ct);
        }

        public async Task<List<Doctor>> GetBySpecializationAsync(
            string specialization,
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Include(d => d.Files)
                .Where(d => d.IsActive &&
                    d.Specialization.ToLower().Contains(specialization.ToLower()))
                .OrderByDescending(d => d.AverageRating)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(ct);
        }

        public async Task<int> CountBySpecializationAsync(
            string specialization,
            CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Where(d => d.IsActive &&
                    d.Specialization.ToLower().Contains(specialization.ToLower()))
                .CountAsync(ct);
        }

        public async Task<List<string>> GetDistinctSpecializationsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Where(d => d.IsActive && !string.IsNullOrEmpty(d.Specialization))
                .Select(d => d.Specialization)
                .Distinct()
                .OrderBy(s => s)
                .ToListAsync(ct);
        }

        public async Task<List<Doctor>> GetTopRatedDoctorsAsync(
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Include(d => d.Files)
                .Where(d => d.IsActive)
                .OrderByDescending(d => d.AverageRating)
                .ThenByDescending(d => d.YearsOfExperience)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(ct);
        }

        public async Task<int> CountTopRatedDoctorsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Where(d => d.IsActive)
                .CountAsync(ct);
        }

        public async Task<List<Doctor>> GetAllDoctorsPagedAsync(
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Include(d => d.User)
                .Include(d => d.Files)
                .Where(d => d.IsActive)
                .OrderByDescending(d => d.AverageRating)
                .ThenByDescending(d => d.YearsOfExperience)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(ct);
        }

        public async Task<int> CountAllDoctorsAsync(CancellationToken ct = default)
        {
            return await _context.Doctors
                .AsNoTracking()
                .Where(d => d.IsActive)
                .CountAsync(ct);
        }

        public async Task<Dictionary<int, int>> GetReviewCountsByDoctorIdsAsync(
            List<int> doctorIds,
            CancellationToken ct = default)
        {
            return await _context.Reviews
                .AsNoTracking()
                .Where(r => r.TargetType == ReviewTargetTypes.Doctor
                         && doctorIds.Contains(r.TargetID))
                .GroupBy(r => r.TargetID)
                .Select(g => new { DoctorId = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.DoctorId, x => x.Count, ct);
        }
    }
}

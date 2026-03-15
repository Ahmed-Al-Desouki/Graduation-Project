// API/Controllers/DoctorSearchController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Interfaces.Search;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/doctors/search")]
    [Authorize]
    public class DoctorSearchController : ControllerBase
    {
        private readonly IDoctorSearchService _searchService;
        private readonly ILogger<DoctorSearchController> _logger;

        public DoctorSearchController(
            IDoctorSearchService searchService,
            ILogger<DoctorSearchController> logger)
        {
            _searchService = searchService;
            _logger = logger;
        }


        // البحث عن دكاترة بالاسم أو التخصص مع pagination
        [HttpGet]
        public async Task<IActionResult> Search(
            [FromQuery] string? query = null,
            [FromQuery] string? specialization = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken ct = default)
        {
            var result = await _searchService.SearchAsync(query, specialization, page, pageSize, ct);

            if (!result.IsSuccess)
                return BadRequest(new { error = result.ErrorMessage });

            return Ok(result);
        }

        [HttpGet("specializations")]
        public async Task<IActionResult> GetSpecializations(CancellationToken ct)
        {
            var result = await _searchService.GetAllSpecializationsAsync(ct);
            return Ok(result);
        }

        [HttpGet("top-rated")]
        public async Task<IActionResult> GetTopRated(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken ct = default)
        {
            var result = await _searchService.GetTopRatedDoctorsAsync(page, pageSize, ct);
            return Ok(result);
        }

        [HttpGet("all")]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken ct = default)
        {
            var result = await _searchService.GetAllDoctorsAsync(page, pageSize, ct);
            return Ok(result);
        }


        // إعادة بناء الـ index (للـ admin بس)
        [HttpPost("rebuild-index")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RebuildIndex(CancellationToken ct)
        {
            await _searchService.RebuildIndexAsync(ct);
            return Ok(new { message = "Search index rebuilt successfully" });
        }
    }
}
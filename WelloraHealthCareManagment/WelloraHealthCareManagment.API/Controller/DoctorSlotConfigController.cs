using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.Interfaces;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/doctors/{doctorId}/slot-config")]
    public class DoctorSlotConfigController : ControllerBase
    {
        private readonly IDoctorSlotConfigService _service;
        private readonly ISlotGenerationService _slotGenerationService;
        private readonly ILogger<DoctorSlotConfigController> _logger;

        public DoctorSlotConfigController(
            IDoctorSlotConfigService service,
            ISlotGenerationService slotGenerationService,
            ILogger<DoctorSlotConfigController> logger)
        {
            _service = service;
            _slotGenerationService = slotGenerationService;
            _logger = logger;
        }


        // Config endpoints
        /// GET api/doctors/5/slot-config
        /// جلب كل إعدادات الأيام للدكتور
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetConfigs(
            int doctorId,
            CancellationToken ct)
        {
            var configs = await _service.GetConfigsAsync(doctorId, ct);
            return Ok(configs);
        }

        /// PUT api/doctors/5/slot-config/days/Monday
        /// إضافة أو تعديل يوم (upsert)
        [HttpPut("days/{day}")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> SetDayConfig(
            int doctorId,
            DayOfWeek day,
            [FromBody] SetDayConfigRequest request,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                request.DayOfWeek = day;
                await _service.SetDayConfigAsync(doctorId, request, ct);
                return Ok(new { message = $"{day} config saved successfully" });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting day config for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        /// DELETE api/doctors/5/slot-config/days/Monday
        /// إلغاء يوم + block كل slots المستقبلية ليه
        [HttpDelete("days/{day}")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> RemoveDay(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                await _service.RemoveDayAsync(doctorId, day, ct);
                return Ok(new
                {
                    message = $"{day} removed and future slots blocked"
                });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing day for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        // Generation endpoint
        /// POST api/doctors/5/slot-config/generate
        /// توليد slots يدوياً لفترة معينة
        [HttpPost("generate")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> GenerateSlots(
            int doctorId,
            [FromBody] GenerateSlotsByConfigRequest request,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                var result = await _slotGenerationService.GenerateAsync(doctorId, request, ct);
                return Ok(result);
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating slots for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        // Exceptions endpoints
        /// POST api/doctors/5/slot-config/exceptions/day-off
        /// إضافة يوم إجازة
        [HttpPost("exceptions/day-off")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> AddDayOff(
            int doctorId,
            [FromBody] CreateDayOffRequest request,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                await _service.AddDayOffAsync(doctorId, request, ct);
                return Ok(new { message = "Day off added successfully" });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding day off for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        /// POST api/doctors/5/slot-config/exceptions/custom-hours
        /// إضافة ساعات مخصصة ليوم معين
        [HttpPost("exceptions/custom-hours")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> AddCustomHours(
            int doctorId,
            [FromBody] CreateCustomHoursRequest request,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                await _service.AddCustomHoursAsync(doctorId, request, ct);
                return Ok(new { message = "Custom hours added successfully" });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        /// DELETE api/doctors/5/slot-config/exceptions/2025-06-15
        /// حذف exception + إعادة توليد slots اليوم ده
        [HttpDelete("exceptions/{date}")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> RemoveException(
            int doctorId,
            DateTime date,
            CancellationToken ct)
        {
            try
            {
                EnsureDoctorOwnershipOrAdmin(doctorId);
                await _service.RemoveExceptionAsync(doctorId, date, ct);
                return Ok(new
                {
                    message = "Exception removed and slots restored successfully"
                });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing exception for doctor {DoctorId}", doctorId);
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        private void EnsureDoctorOwnershipOrAdmin(int doctorId)
        {
            if (User.IsInRole("Admin"))
                return;

            var claim = User.FindFirst("UserID") ?? User.FindFirst(ClaimTypes.NameIdentifier);
            if (!int.TryParse(claim?.Value, out var currentDoctorId) || currentDoctorId != doctorId)
                throw new UnauthorizedAccessException("You are not allowed to modify another doctor's schedule.");
        }
    }
}

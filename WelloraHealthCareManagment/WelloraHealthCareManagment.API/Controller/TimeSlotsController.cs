using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.Common.Security;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/doctors/{doctorId}/time-slots")]
    public class TimeSlotsController : ControllerBase
    {
        private readonly ITimeSlotService _timeSlotService;
        private readonly ILogger<TimeSlotsController> _logger;

        public TimeSlotsController(
            ITimeSlotService timeSlotService,
            ILogger<TimeSlotsController> logger)
        {
            _timeSlotService = timeSlotService;
            _logger = logger;
        }

        [HttpGet("available")]
        [AllowAnonymous]
        public async Task<IActionResult> GetAvailableSlots(
            int doctorId,
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            var slots = await _timeSlotService.GetAvailableSlotsAsync(doctorId, startDate, endDate);
            return Ok(slots);
        }

        [HttpPost("manual")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOrAdminPolicy)]
        public async Task<IActionResult> CreateManualSlot(
            int doctorId,
            [FromBody] CreateManualSlotRequest request)
        {
            try
            {
                var slotId = await _timeSlotService.CreateManualSlotAsync(
                    doctorId,
                    request.SlotDate,
                    request.StartTime,
                    request.EndTime,
                    GetUserId(),
                    GetUserRole());

                return Ok(new { slotId, message = "Manual slot created successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating manual slot for doctor {DoctorId}", doctorId);
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpDelete("{slotId}")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOrAdminPolicy)]
        public async Task<IActionResult> DeleteSlot(Guid slotId)
        {
            try
            {
                await _timeSlotService.DeleteSlotAsync(slotId, GetUserId(), GetUserRole());
                return Ok(new { message = "Slot deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting slot {SlotId}", slotId);
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("range")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOrAdminPolicy)]
        public async Task<IActionResult> GetTimeSlotsInRange(
            int doctorId,
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] string? status = null)
        {
            try
            {
                var result = await _timeSlotService.GetDoctorTimeSlotsInRangeAsync(
                    doctorId,
                    startDate,
                    endDate,
                    status,
                    GetUserId(),
                    GetUserRole(),
                    HttpContext.RequestAborted);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Error fetching time slots for doctor {DoctorId} from {Start} to {End}",
                    doctorId,
                    startDate,
                    endDate);
                return StatusCode(500, new { error = "An error occurred while fetching time slots" });
            }
        }

        [HttpPatch("{slotId}/block")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOrAdminPolicy)]
        public async Task<IActionResult> BlockSlot(Guid slotId)
        {
            try
            {
                await _timeSlotService.BlockSlotAsync(slotId, GetUserId(), GetUserRole());
                return Ok(new { message = "Slot blocked successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error blocking slot {SlotId}", slotId);
                return BadRequest(new { error = ex.Message });
            }
        }

        private int GetUserId()
        {
            var value = User.FindFirst("UserID")?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new UnauthorizedAccessException("User identifier claim is missing.");

            return int.Parse(value);
        }

        private string GetUserRole()
        {
            return User.FindFirst(ClaimTypes.Role)?.Value
                ?? User.FindFirst("Role")?.Value
                ?? string.Empty;
        }
    }

    public class CreateManualSlotRequest
    {
        public DateTime SlotDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }
}

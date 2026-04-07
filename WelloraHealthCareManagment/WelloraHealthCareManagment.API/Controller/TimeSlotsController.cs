using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagement.Application.Interfaces;
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

        /// جلب الخانات المتاحة (للمرضى)
        [HttpGet("available")]
        [AllowAnonymous]
        public async Task<IActionResult> GetAvailableSlots(
            int doctorId,
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            var slots = await _timeSlotService.GetAvailableSlotsAsync(
                doctorId, startDate, endDate);

            return Ok(slots);
        }

        /// إضافة خانة يدوية
        [HttpPost("manual")]
        [Authorize(Roles = "Doctor")]
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
                    request.EndTime);

                return Ok(new { slotId, message = "Manual slot created successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating manual slot");
                return BadRequest(new { error = ex.Message });
            }
        }

        /// حذف خانة
        [HttpDelete("{slotId}")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> DeleteSlot(Guid slotId)
        {
            try
            {
                await _timeSlotService.DeleteSlotAsync(slotId);
                return Ok(new { message = "Slot deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting slot {SlotId}", slotId);
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("range")]
        [Authorize] // أو [AllowAnonymous] لو عايز المرضى يشوفوا بدون login
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
                    HttpContext.RequestAborted);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching time slots for doctor {DoctorId} from {Start} to {End}",
                    doctorId, startDate, endDate);
                return StatusCode(500, new { error = "An error occurred while fetching time slots" });
            }
        }

        /// حظر خانة
        [HttpPatch("{slotId}/block")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> BlockSlot(Guid slotId)
        {
            try
            {
                await _timeSlotService.BlockSlotAsync(slotId);
                return Ok(new { message = "Slot blocked successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error blocking slot {SlotId}", slotId);
                return BadRequest(new { error = ex.Message });
            }
        }
    }

    public class CreateManualSlotRequest
    {
        public DateTime SlotDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }
}
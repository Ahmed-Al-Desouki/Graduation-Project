using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/doctors/{doctorId}/schedules")]
    [Authorize(Roles = "Doctor")]
    public class DoctorScheduleController : ControllerBase
    {
        private readonly IDoctorScheduleService _scheduleService;
        private readonly ILogger<DoctorScheduleController> _logger;

        public DoctorScheduleController(
            IDoctorScheduleService scheduleService,
            ILogger<DoctorScheduleController> logger)
        {
            _scheduleService = scheduleService;
            _logger = logger;
        }

        /// إنشاء جدول جديد للطبيب
        //[HttpPost]
        //public async Task<IActionResult> CreateSchedule(
        //    int doctorId,
        //    [FromBody] CreateScheduleRequest request)
        //{
        //    try
        //    {
        //        var scheduleId = await _scheduleService.CreateScheduleAsync(
        //            doctorId, request);

        //        return Ok(new { scheduleId, message = "Schedule created successfully" });
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error creating schedule for doctor {DoctorId}", doctorId);
        //        return BadRequest(new { error = ex.Message });
        //    }
        //}
        // Update existing schedule and generate slots for new days

        // Create schedule (supports "For Life" schedules)
        [HttpPost]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> CreateSchedule(
            int doctorId,
            [FromBody] CreateScheduleRequest request)
        {
            try
            {
                var templateId = await _scheduleService.CreateScheduleAsync(doctorId, request);

                return CreatedAtAction(
                    nameof(GetActiveSchedule),
                    new { doctorId },
                    new
                    {
                        templateId,
                        message = request.EffectiveToDate.HasValue
                            ? "Schedule created successfully"
                            : "Open-ended schedule created (For Life)"
                    });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating schedule");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        [HttpPut]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> UpdateSchedule(
            int doctorId,
            [FromBody] UpdateScheduleRequest request)
        {
            try
            {
                await _scheduleService.UpdateScheduleAsync(doctorId, request);
                return Ok(new { message = "Schedule updated and slots generated for new days" });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating schedule");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        // جلب الجدول النشط للطبيب
        [HttpGet("active")]
        public async Task<IActionResult> GetActiveSchedule(int doctorId)
        {
            var schedule = await _scheduleService.GetActiveScheduleAsync(doctorId);

            if (schedule == null)
                return NotFound(new { error = "No active schedule found" });

            return Ok(schedule);
        }

        /// إضافة إجازة
        [HttpPost("exceptions/day-off")]
        public async Task<IActionResult> AddDayOff(
            int doctorId,
            [FromBody] CreateDayOffRequest request)
        {
            try
            {
                await _scheduleService.AddDayOffAsync(doctorId, request);
                return Ok(new { message = "Day off added successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding day off for doctor {DoctorId}", doctorId);
                return BadRequest(new { error = ex.Message });
            }
        }

        /// إضافة ساعات عمل مخصصة
        [HttpPost("exceptions/custom-hours")]
        public async Task<IActionResult> AddCustomHours(
            int doctorId,
            [FromBody] CreateCustomHoursRequest request)
        {
            try
            {
                await _scheduleService.AddCustomHoursAsync(doctorId, request);
                return Ok(new { message = "Custom hours added successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
                return BadRequest(new { error = ex.Message });
            }
        }

        /// حذف استثناء
        [HttpDelete("exceptions/{date}")]
        public async Task<IActionResult> RemoveException(
            int doctorId,
            DateTime date)
        {
            try
            {
                await _scheduleService.RemoveExceptionAsync(doctorId, date);
                return Ok(new { message = "Exception removed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing exception for doctor {DoctorId}", doctorId);
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/appointments")]
    [Authorize]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly ILogger<AppointmentsController> _logger;

        public AppointmentsController(
            IAppointmentService appointmentService,
            ILogger<AppointmentsController> logger)
        {
            _appointmentService = appointmentService;
            _logger = logger;
        }

        /// حجز موعد (للمريض)
        [HttpPost("book")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> BookAppointment(
            [FromBody] BookAppointmentRequest request)
        {
            try
            {
                var patientId = GetUserId();

                var response = await _appointmentService.BookAppointmentAsync(
                    patientId, request);

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error booking appointment");
                return BadRequest(new { error = ex.Message });
            }
        }

        /// جلب تفاصيل موعد
        [HttpGet("{appointmentId}")]
        public async Task<IActionResult> GetAppointmentDetails(Guid appointmentId)
        {
            var appointment = await _appointmentService.GetAppointmentDetailsAsync(appointmentId);

            if (appointment == null)
                return NotFound(new { error = "Appointment not found" });

            return Ok(appointment);
        }

        /// جلب مواعيد المريض
        [HttpGet("my-appointments")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> GetMyAppointments(
            [FromQuery] AppointmentStatus? status = null)
        {
            var patientId = GetUserId();

            var appointments = await _appointmentService.GetPatientAppointmentsAsync(
                patientId, status);

            return Ok(appointments);
        }

        /// جلب مواعيد الطبيب
        [HttpGet("doctor-appointments")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> GetDoctorAppointments(
            [FromQuery] DateTime? date = null,
            [FromQuery] AppointmentStatus? status = null)
        {
            var doctorId = GetUserId();

            var appointments = await _appointmentService.GetDoctorAppointmentsAsync(
                doctorId, date, status);

            return Ok(appointments);
        }

        [HttpPost("{originalAppointmentId}/follow-up/existing")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> BookFollowUpExisting(
            Guid originalAppointmentId,
            [FromBody] BookFollowUpExistingRequest request)
        {
            try
            {
                var doctorId = GetUserId();
                var response = await _appointmentService.BookFollowUpOnExistingSlotAsync(
                    originalAppointmentId, request, doctorId);
                return Ok(response);
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in follow-up");
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        [HttpPost("{originalAppointmentId}/follow-up/new")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CreateAndBookFollowUp(
            Guid originalAppointmentId,
            [FromBody] BookFollowUpNewRequest request)
        {
            try
            {
                var doctorId = GetUserId();
                var response = await _appointmentService.CreateAndBookFollowUpSlotAsync(
                    originalAppointmentId, request, doctorId);
                return Ok(response);
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in follow-up");
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        // Cancel by patient - restores slot availability
        [HttpPatch("{appointmentId}/patient-cancel")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> CancelByPatient(
            Guid appointmentId,
            [FromBody] CancelAppointmentRequest request)
        {
            try
            {
                var patientId = GetUserId();
                await _appointmentService.CancelByPatientAsync(appointmentId, patientId, request);
                return Ok(new { message = "Appointment cancelled successfully by patient" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in patient cancel for appointment {AppointmentId}", appointmentId);
                return BadRequest(new { error = ex.Message });
            }
        }

        // Cancel and block by doctor - prevents re-booking of the slot
        [HttpPatch("{appointmentId}/doctor-cancel-block")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CancelAndBlockByDoctor(
            Guid appointmentId,
            [FromBody] CancelAppointmentRequest request)
        {
            try
            {
                var doctorId = GetUserId();
                await _appointmentService.CancelAndBlockByDoctorAsync(appointmentId, doctorId, request);
                return Ok(new { message = "Appointment cancelled and slot blocked successfully by doctor" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in doctor cancel-block for appointment {AppointmentId}", appointmentId);
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("{appointmentId}/grant-medical-access")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> GrantMedicalAccess(Guid appointmentId)
        {
            var patientId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _appointmentService.GrantMedicalHistoryAccessAsync(patientId, appointmentId);
            return Ok(new { message = "Medical history access granted successfully" });
        }

        /// تأكيد موعد (للطبيب)
        [HttpPatch("{appointmentId}/confirm")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> ConfirmAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.ConfirmAppointmentAsync(appointmentId);
                return Ok(new { message = "Appointment confirmed" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming appointment {AppointmentId}", appointmentId);
                return BadRequest(new { error = ex.Message });
            }
        }

        /// بدء موعد (للطبيب)
        [HttpPatch("{appointmentId}/start")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> StartAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.StartAppointmentAsync(appointmentId);
                return Ok(new { message = "Appointment started" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error starting appointment {AppointmentId}", appointmentId);
                return BadRequest(new { error = ex.Message });
            }
        }

        /// إكمال موعد (للطبيب)
        [HttpPatch("{appointmentId}/complete")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CompleteAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.CompleteAppointmentAsync(appointmentId);
                return Ok(new { message = "Appointment completed" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error completing appointment {AppointmentId}", appointmentId);
                return BadRequest(new { error = ex.Message });
            }
        }

        // Helper methods
        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.Parse(userIdClaim!);
        }

        private string GetUserRole()
        {
            return User.FindFirst(ClaimTypes.Role)?.Value ?? "Unknown";
        }
    }
}
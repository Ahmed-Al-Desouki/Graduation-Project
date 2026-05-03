using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.Common.Security;
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

        ///// حجز موعد (للمريض)
        //[HttpPost("book")]
        //[Authorize(Roles = "Patient")]
        //public async Task<IActionResult> BookAppointment([FromBody] BookAppointmentRequest request)
        //{
        //    try
        //    {
        //        var patientId = GetUserId();
        //        var response = await _appointmentService.BookAppointmentAsync(patientId, request);
        //        return Ok(response);
        //    }
        //    catch (NotFoundException ex)
        //    {
        //        return NotFound(new { error = ex.Message });
        //    }
        //    catch (DomainException ex)
        //    {
        //        return BadRequest(new { error = ex.Message });
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error booking appointment");
        //        return StatusCode(500, new { error = "An unexpected error occurred" });
        //    }
        //}
        /// <summary>
        /// حجز موعد مع الدفع (Payment First Flow)
        /// </summary>
        [HttpPost("book-with-payment")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> BookAppointmentWithPayment(
            [FromBody] BookAppointmentRequest request,
            [FromQuery] PaymentMethod paymentMethod = PaymentMethod.Card)
        {
            try
            {
                var patientId = GetUserId();

                var response = await _appointmentService.InitiateBookingWithPaymentAsync(
                    patientId,
                    request,
                    paymentMethod);

                return Ok(response);
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in BookAppointmentWithPayment");
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }
        /// جلب تفاصيل موعد
        [HttpGet("{appointmentId}")]
        public async Task<IActionResult> GetAppointmentDetails(Guid appointmentId)
        {
            var appointment = await _appointmentService.GetAppointmentDetailsAsync(
                appointmentId,
                GetUserId(),
                GetUserRole());

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
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
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
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
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
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
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

        // Cancel and block by doctor - prevents re-booking of the slot
        [HttpPost("{appointmentId}/cancel-patient")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> CancelAppointmentByPatient(
                Guid appointmentId,
                [FromBody] CancelAppointmentRequest request)
        {
            try
            {
                var patientId = GetUserId();
                var result = await _appointmentService.CancelByPatientAsync(
                    appointmentId,
                    patientId,
                    request);

                if (!result.Success)
                    return BadRequest(new { message = result.Message });

                return Ok(new
                {
                    message = result.Message,
                    refundAmount = result.RefundAmount,
                    refundPercentage = result.RefundPercentage,
                    refundProcessed = result.RefundProcessed
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { message = "An error occurred while cancelling the appointment" });
            }
        }

        [HttpPost("{appointmentId}/doctor-cancel-block")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
        public async Task<IActionResult> CancelAppointmentByDoctor(
        Guid appointmentId,
        [FromBody] CancelAppointmentRequest request)
        {
            try
            {
                var doctorId = GetUserId();
                var result = await _appointmentService.CancelAndBlockByDoctorAsync(
                    appointmentId,
                    doctorId,
                    request);

                if (!result.Success)
                    return BadRequest(new { message = result.Message });

                return Ok(new
                {
                    message = result.Message,
                    refundAmount = result.RefundAmount,
                    refundPercentage = result.RefundPercentage,
                    refundProcessed = result.RefundProcessed
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { message = "An error occurred while cancelling the appointment" });
            }
        }

        // Toggle / Update / Revoke All
        [HttpPost("{appointmentId}/grant-medical-access")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> ToggleMedicalAccess(
            Guid appointmentId,
            [FromBody] ToggleMedicalAccessRequest request)
        {
            try
            {
                var patientId = GetUserId();
                await _appointmentService.ToggleMedicalHistoryAccessAsync(
                    patientId, appointmentId, request);

                return Ok(new
                {
                    message = "Medical history access updated successfully",
                    revokeAll = request.RevokeAll
                });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
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
                _logger.LogError(ex, "Error toggling medical access for appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        [HttpPost("{appointmentId}/extend-medical-access")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> ExtendMedicalAccess(
            Guid appointmentId,
            [FromBody] ExtendAccessRequest request)
        {
            try
            {
                var patientId = GetUserId();
                await _appointmentService.ExtendMedicalAccessExpiryAsync(
                    patientId, appointmentId, request);

                return Ok(new { message = "Medical access expiry extended successfully" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
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
                _logger.LogError(ex, "Error extending medical access for appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        /// تأكيد موعد (للطبيب)
        [HttpPatch("{appointmentId}/confirm")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
        public async Task<IActionResult> ConfirmAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.ConfirmAppointmentAsync(appointmentId, GetUserId());
                return Ok(new { message = "Appointment confirmed" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        /// بدء موعد (للطبيب)
        [HttpPatch("{appointmentId}/start")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
        public async Task<IActionResult> StartAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.StartAppointmentAsync(appointmentId, GetUserId());
                return Ok(new { message = "Appointment started" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error starting appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { error = "An unexpected error occurred" });
            }
        }

        /// إكمال موعد (للطبيب)
        [HttpPatch("{appointmentId}/complete")]
        [Authorize(Policy = DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy)]
        public async Task<IActionResult> CompleteAppointment(Guid appointmentId)
        {
            try
            {
                await _appointmentService.CompleteAppointmentAsync(appointmentId, GetUserId());
                return Ok(new { message = "Appointment completed" });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (DomainException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error completing appointment {AppointmentId}", appointmentId);
                return StatusCode(500, new { error = "An unexpected error occurred" });
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

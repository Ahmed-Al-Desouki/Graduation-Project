using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/appointments/{appointmentId}/medical-record")]
    [Authorize]
    public class MedicalRecordsController : ControllerBase
    {
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly ILogger<MedicalRecordsController> _logger;

        public MedicalRecordsController(
            IMedicalRecordService medicalRecordService,
            ILogger<MedicalRecordsController> logger)
        {
            _medicalRecordService = medicalRecordService;
            _logger = logger;
        }


        /// Create medical record for appointment (Doctor only)
        [HttpPost]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CreateMedicalRecord(
            Guid appointmentId,
            [FromBody] CreateMedicalRecordRequest request)
        {
            try
            {
                var doctorId = GetCurrentDoctorId();

                var recordId = await _medicalRecordService.CreateMedicalRecordAsync(
                    appointmentId,
                    doctorId,
                    request);

                return CreatedAtAction(
                    nameof(GetMedicalRecord),
                    new { appointmentId },
                    new { id = recordId, message = "Medical record created successfully" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating medical record");
                return StatusCode(500, new { error = "An error occurred while creating medical record" });
            }
        }


        /// Update medical record (Doctor only)
        [HttpPut]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> UpdateMedicalRecord(
            Guid appointmentId,
            [FromBody] UpdateMedicalRecordRequest request)
        {
            try
            {
                var doctorId = GetCurrentDoctorId();

                await _medicalRecordService.UpdateMedicalRecordAsync(
                    appointmentId,
                    doctorId,
                    request);

                return Ok(new { message = "Medical record updated successfully" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating medical record");
                return StatusCode(500, new { error = "An error occurred while updating medical record" });
            }
        }


        /// Get medical record for appointment
        [HttpGet]
        public async Task<IActionResult> GetMedicalRecord(Guid appointmentId)
        {
            try
            {
                var record = await _medicalRecordService.GetMedicalRecordAsync(
                    appointmentId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                if (record == null)
                    return NotFound(new { error = "Medical record not found" });

                return Ok(record);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical record");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(userIdClaim, out int userId))
                return userId;

            throw new UnauthorizedAccessException("User ID not found in token");
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirst("Role")?.Value
                ?? User.FindFirst(ClaimTypes.Role)?.Value
                ?? string.Empty;
        }

        private int GetCurrentDoctorId()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(userIdClaim, out int doctorId))
                return doctorId;

            throw new UnauthorizedAccessException("Doctor ID not found in token");
        }
    }
}

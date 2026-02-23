using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Prescriptions;

namespace WelloraHealthCareManagement.API.Controllers
{
    [ApiController]
    [Route("api/prescriptions")]
    [Authorize]
    public class PrescriptionsController : ControllerBase
    {
        private readonly IPrescriptionService _prescriptionService;
        private readonly ILogger<PrescriptionsController> _logger;

        public PrescriptionsController(
            IPrescriptionService prescriptionService,
            ILogger<PrescriptionsController> logger)
        {
            _prescriptionService = prescriptionService;
            _logger = logger;
        }


        /// Create prescription for appointment (Doctor only)
        [HttpPost]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CreatePrescription(
            [FromBody] CreatePrescriptionRequest request)
        {
            try
            {
                var doctorId = GetCurrentDoctorId();

                var prescription = await _prescriptionService.CreatePrescriptionAsync(
                    doctorId,
                    request);

                return CreatedAtAction(
                    nameof(GetPrescription),
                    new { id = prescription.PrescriptionId },
                    prescription);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating prescription");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        /// Get prescription by ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPrescription(Guid id)
        {
            try
            {
                var prescription = await _prescriptionService.GetPrescriptionAsync(id);

                if (prescription == null)
                    return NotFound(new { error = "Prescription not found" });

                return Ok(prescription);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescription");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        /// Get all prescriptions for appointment
        [HttpGet("appointment/{appointmentId}")]
        public async Task<IActionResult> GetAppointmentPrescriptions(Guid appointmentId)
        {
            try
            {
                var prescriptions = await _prescriptionService.GetAppointmentPrescriptionsAsync(
                    appointmentId);

                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        /// Get all patient prescriptions (Patient only)
        [HttpGet("my-prescriptions")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> GetMyPrescriptions()
        {
            try
            {
                var patientId = GetCurrentPatientId();

                var prescriptions = await _prescriptionService.GetPatientPrescriptionsAsync(
                    patientId);

                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }


        /// Add item to prescription (Doctor only)
        [HttpPost("{prescriptionId}/items/bulk")]
        public async Task<IActionResult> AddPrescriptionItems(
            Guid prescriptionId,
            [FromBody] AddPrescriptionItemsRequest request)
        {
            try
            {
                var doctorId = GetCurrentDoctorId();

                await _prescriptionService.AddPrescriptionItemsAsync(
                      prescriptionId,
                      doctorId,
                      request,
                      CancellationToken.None);

                return Ok(new { message = "Item added successfully" });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding prescription item");
                return StatusCode(500, new { error = "An error occurred" });
            }
        }

        private int GetCurrentDoctorId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.Parse(userIdClaim!);

            throw new UnauthorizedAccessException("Doctor ID not found in token");
        }

        private int GetCurrentPatientId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out int patientId))
                return patientId;

            throw new UnauthorizedAccessException("Patient ID not found in token");
        }
    }
}
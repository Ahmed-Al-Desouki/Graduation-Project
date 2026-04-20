// API/Controllers/PaymentController.cs

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.Payment;

namespace WelloraHealthCareManagement.API.Controllers
{       
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly IPaymentService _paymentService;
        private readonly ILogger<PaymentController> _logger;

        public PaymentController(
            IPaymentService paymentService,
            ILogger<PaymentController> logger,
            IConfiguration configuration)
        {
            _paymentService = paymentService;
            _logger = logger;
            _configuration = configuration;
        }


        [HttpPost("paymob-callback")]
        public async Task<IActionResult> PaymobCallback([FromBody] PaymobCallbackRequest callback)
        {
            var hmac = Request.Query["hmac"].FirstOrDefault()
                ?? Request.Headers["hmac"].FirstOrDefault()
                ?? Request.Form["hmac"].FirstOrDefault();

            await _paymentService.ProcessPaymobCallbackAsync(
                callback,
                hmac,
                CancellationToken.None);

            return Ok("received");
        }

        /// Transaction Response Callback - User redirect after payment
        [HttpGet("payment-result")]
        public async Task<IActionResult> PaymentResult(
            [FromQuery(Name = "merchant_order_id")] string? merchantOrderId,
            [FromQuery] bool success)
        {
            var redirectUrl = await _paymentService.HandlePaymentResultRedirectAsync(
                merchantOrderId, success);
            return Redirect(redirectUrl);
        }

        /// Create payment for appointment booking
        /// Create payment for booking (يدعم TimeSlotId أو AppointmentId)
        [HttpPost("create")]
        [Authorize(Roles = "Patient,Admin")]
        public async Task<IActionResult> CreatePayment([FromBody] CreatePaymentRequest request)
        {
            var result = await _paymentService.CreatePaymentAsync(
                request,
                GetUserId(),
                GetUserRole(),
                CancellationToken.None);
            return Ok(result);
        }

        /// Refund a payment
        [HttpPost("refund")]
        [Authorize(Roles = "Patient,Doctor,Admin")]
        public async Task<IActionResult> RefundPayment([FromBody] RefundPaymentRequest request)
        {
            var result = await _paymentService.RefundPaymentAsync(
                request,
                GetUserId(),
                GetUserRole(),
                CancellationToken.None);

            if (result.Success)
                return Ok(result);

            return BadRequest(result);
        }

        /// Get payment details by appointment ID
        [HttpGet("appointment/{appointmentId:guid}")]
        [Authorize(Roles = "Patient,Doctor,Admin")]
        public async Task<IActionResult> GetPaymentByAppointment(Guid appointmentId)
        {
            var payment = await _paymentService.GetPaymentByAppointmentIdAsync(
                appointmentId,
                GetUserId(),
                GetUserRole(),
                CancellationToken.None);

            if (payment == null)
                return NotFound(new { message = "Payment not found" });

            return Ok(payment);
        }

        /// Get payment history for patient
        [HttpGet("patient/{patientId:int}/history")]
        [Authorize(Roles = "Patient,Admin")]
        public async Task<IActionResult> GetPatientPaymentHistory(int patientId)
        {
            var payments = await _paymentService.GetPatientPaymentHistoryAsync(
                patientId,
                GetUserId(),
                GetUserRole(),
                CancellationToken.None);

            return Ok(payments);
        }

        /// GET: api/payment/test-config
        [HttpGet("test-config")]
        [Authorize(Roles = "Admin")]
        public IActionResult TestConfiguration()
        {
            var apiKey = _configuration["Paymob:ApiKey"];
            var hmacSecret = _configuration["Paymob:HmacSecret"];
            var cardIntegrationId = _configuration["Paymob:IntegrationId:Card"];
            var cardIframeId = _configuration["Paymob:IframeId:Card"];

            return Ok(new
            {
                ApiKeyConfigured = !string.IsNullOrEmpty(apiKey),
                ApiKeyLength = apiKey?.Length ?? 0,
                HmacSecretConfigured = !string.IsNullOrEmpty(hmacSecret),
                HmacSecretLength = hmacSecret?.Length ?? 0,
                CardIntegrationId = cardIntegrationId,
                CardIframeId = cardIframeId
            });
        }

        private int GetUserId()
        {
            var claim = User.FindFirst("UserID") ?? User.FindFirst(ClaimTypes.NameIdentifier);
            return int.TryParse(claim?.Value, out var userId) ? userId : 0;
        }

        private string GetUserRole()
        {
            return User.FindFirst("Role")?.Value
                ?? User.FindFirst(ClaimTypes.Role)?.Value
                ?? string.Empty;
        }

    }
}

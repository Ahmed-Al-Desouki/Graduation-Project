// Infrastructure/Services/PaymobService.cs

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using RestSharp;
using System.Security.Cryptography;
using System.Text;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.Payment;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class PaymobService : IPaymobService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<PaymobService> _logger;
        private readonly string _apiKey;
        private readonly string _hmacSecret;
        private readonly Dictionary<PaymentMethod, int> _integrationIds;
        private readonly Dictionary<PaymentMethod, string> _iframeIds;
        private readonly string _baseUrl = "https://accept.paymob.com/api";

        public PaymobService(
            IConfiguration configuration,
            ILogger<PaymobService> logger)
        {
            _configuration = configuration;
            _logger = logger;

            _apiKey = _configuration["Paymob:ApiKey"]
                ?? throw new InvalidOperationException("Paymob API Key not configured");

            _hmacSecret = _configuration["Paymob:HmacSecret"]
                ?? throw new InvalidOperationException("Paymob HMAC Secret not configured");

            // Integration IDs
            _integrationIds = new Dictionary<PaymentMethod, int>
            {
                { PaymentMethod.Card, int.Parse(_configuration["Paymob:IntegrationId:Card"] ?? "0") },
                { PaymentMethod.VodafoneCash, int.Parse(_configuration["Paymob:IntegrationId:VodafoneCash"] ?? "0") },//في المستقبل ان شاء الله
                { PaymentMethod.EtisalatCash, int.Parse(_configuration["Paymob:IntegrationId:EtisalatCash"] ?? "0") },
                { PaymentMethod.OrangeCash, int.Parse(_configuration["Paymob:IntegrationId:OrangeCash"] ?? "0") },
                { PaymentMethod.WePay, int.Parse(_configuration["Paymob:IntegrationId:WePay"] ?? "0") },
                { PaymentMethod.Valu, int.Parse(_configuration["Paymob:IntegrationId:Valu"] ?? "0") },
                { PaymentMethod.Souhoola, int.Parse(_configuration["Paymob:IntegrationId:Souhoola"] ?? "0") },
                { PaymentMethod.BankInstallment, int.Parse(_configuration["Paymob:IntegrationId:BankInstallment"] ?? "0") }
            };

            // iFrame IDs
            _iframeIds = new Dictionary<PaymentMethod, string>
            {
                { PaymentMethod.Card, _configuration["Paymob:IframeId:Card"] ?? "" },
                { PaymentMethod.VodafoneCash, _configuration["Paymob:IframeId:VodafoneCash"] ?? "" },
                { PaymentMethod.EtisalatCash, _configuration["Paymob:IframeId:EtisalatCash"] ?? "" },
                { PaymentMethod.OrangeCash, _configuration["Paymob:IframeId:OrangeCash"] ?? "" },
                { PaymentMethod.WePay, _configuration["Paymob:IframeId:WePay"] ?? "" },
                { PaymentMethod.Valu, _configuration["Paymob:IframeId:Valu"] ?? "" },
                { PaymentMethod.Souhoola, _configuration["Paymob:IframeId:Souhoola"] ?? "" },
                { PaymentMethod.BankInstallment, _configuration["Paymob:IframeId:BankInstallment"] ?? "" }
            };
        }

        #region Public Methods

        //public async Task<CreatePaymentResponse> CreatePaymentAsync(
        //    Guid appointmentId,
        //    decimal amount,
        //    PaymentMethod paymentMethod,
        //    string patientEmail,
        //    string patientPhone,
        //    string patientFirstName,
        //    string patientLastName,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        _logger.LogInformation(
        //            "Creating Paymob payment for appointment {AppointmentId}, Amount: {Amount} EGP",
        //            appointmentId, amount);

        //        // Step 1: Authenticate
        //        var authToken = await AuthenticateAsync(cancellationToken);

        //        // Step 2: Create Order
        //        var orderId = await CreateOrderAsync(
        //            authToken,
        //            amount,
        //            appointmentId.ToString(),
        //            cancellationToken);

        //        // Step 3: Generate Payment Key
        //        var paymentKey = await CreatePaymentKeyAsync(
        //            authToken,
        //            amount,
        //            orderId,
        //            paymentMethod,
        //            patientEmail,
        //            patientPhone,
        //            patientFirstName,
        //            patientLastName,
        //            cancellationToken);

        //        // Step 4: Build Payment URL
        //        var iframeId = GetIframeId(paymentMethod);
        //        var paymentUrl = $"https://accept.paymob.com/api/acceptance/iframes/{iframeId}?payment_token={paymentKey}";

        //        _logger.LogInformation(
        //            "Payment created successfully for appointment {AppointmentId}, Order ID: {OrderId}",
        //            appointmentId, orderId);

        //        return new CreatePaymentResponse
        //        {
        //            PaymentUrl = paymentUrl,
        //            PaymentId = Guid.NewGuid(), // Will be overwritten by caller
        //            PaymobOrderId = orderId.ToString(),
        //            Amount = amount
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error creating Paymob payment for appointment {AppointmentId}", appointmentId);
        //        throw new DomainException("Failed to create payment. Please try again.");
        //    }
        //}
        public async Task<CreatePaymentResponse> CreatePaymentAsync(
            Guid appointmentId,
            decimal amount,
            PaymentMethod paymentMethod,
            string patientEmail,
            string patientPhone,
            string patientFirstName,
            string patientLastName,
            CancellationToken cancellationToken = default)
        {
            _logger.LogInformation(
                "Starting Paymob payment creation for appointment {AppointmentId}, Amount: {Amount} EGP, Method: {Method}",
                appointmentId, amount, paymentMethod);

            try
            {
                // Step 1: Authenticate
                _logger.LogInformation("Step 1: Authenticating with Paymob...");
                var authToken = await AuthenticateAsync(cancellationToken);
                if (string.IsNullOrEmpty(authToken))
                {
                    _logger.LogError("Paymob authentication failed - token is null or empty");
                    return null;
                }
                _logger.LogInformation("Step 1 SUCCESS: Auth token received (length: {Length})", authToken.Length);

                // Step 2: Create Order
                _logger.LogInformation("Step 2: Creating Paymob order...");
                var orderId = await CreateOrderAsync(authToken, amount, appointmentId.ToString(), cancellationToken);
                if (orderId <= 0)
                {
                    _logger.LogError("Paymob order creation failed - returned orderId: {OrderId}", orderId);
                    return null;
                }
                _logger.LogInformation("Step 2 SUCCESS: Order created with ID {OrderId}", orderId);

                // Step 3: Generate Payment Key
                _logger.LogInformation("Step 3: Generating payment key...");
                var paymentKey = await CreatePaymentKeyAsync(
                    authToken, amount, orderId, paymentMethod,
                    patientEmail, patientPhone, patientFirstName, patientLastName, cancellationToken);

                if (string.IsNullOrEmpty(paymentKey))
                {
                    _logger.LogError("Paymob payment key generation failed - key is null or empty");
                    return null;
                }
                _logger.LogInformation("Step 3 SUCCESS: Payment key generated (length: {Length})", paymentKey.Length);

                // Step 4: Build Payment URL
                _logger.LogInformation("Step 4: Building payment URL...");
                var iframeId = GetIframeId(paymentMethod);
                if (string.IsNullOrEmpty(iframeId))
                {
                    _logger.LogError("Iframe ID not found for method {Method}", paymentMethod);
                    return null;
                }

                var paymentUrl = $"https://accept.paymob.com/api/acceptance/iframes/{iframeId}?payment_token={paymentKey}";
                _logger.LogInformation("Paymob payment flow completed. URL: {Url}", paymentUrl);

                return new CreatePaymentResponse
                {
                    PaymentUrl = paymentUrl,
                    PaymentId = Guid.NewGuid(),
                    PaymobOrderId = orderId.ToString(),
                    Amount = amount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Paymob payment creation FAILED for appointment {AppointmentId}", appointmentId);
                return null;
            }
        }

        public async Task<bool> VerifyCallbackAsync(
              PaymobCallbackRequest callback,
              string hmacFromHeader)
        {
            try
            {
                var obj = callback.obj;

                var concatenatedString =
                    obj.amount_cents.ToString() +
                    obj.created_at +
                    obj.currency +
                    obj.error_occured.ToString().ToLower() +
                    obj.has_parent_transaction.ToString().ToLower() +
                    obj.id.ToString() +
                    obj.integration_id.ToString() +
                    obj.is_3d_secure.ToString().ToLower() +
                    obj.is_auth.ToString().ToLower() +
                    obj.is_capture.ToString().ToLower() +
                    obj.is_refunded.ToString().ToLower() +
                    obj.is_standalone_payment.ToString().ToLower() +
                    obj.is_voided.ToString().ToLower() +
                    obj.order.id.ToString() +
                    obj.owner.ToString() +
                    obj.pending.ToString().ToLower() +
                    (obj.source_data?.pan ?? "") +
                    (obj.source_data?.sub_type ?? "") +
                    (obj.source_data?.type ?? "") +
                    obj.success.ToString().ToLower();

                var computedHmac = ComputeHmac(concatenatedString, _hmacSecret);

                var isValid = computedHmac.Equals(hmacFromHeader, StringComparison.OrdinalIgnoreCase);

                if (!isValid)
                {
                    _logger.LogWarning(
                        "HMAC verification failed.\nString: {String}\nExpected: {Computed}\nReceived: {Received}",
                        concatenatedString,
                        computedHmac,
                        hmacFromHeader);
                }

                return isValid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying Paymob callback HMAC");
                return false;
            }
        }

        //public async Task<RefundPaymentResponse> RefundPaymentAsync(
        //    string transactionId,
        //    decimal amountCents,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        _logger.LogInformation(
        //            "Initiating refund for transaction {TransactionId}, Amount: {Amount} piasters",
        //            transactionId, amountCents);

        //        // Authenticate
        //        var authToken = await AuthenticateAsync(cancellationToken);

        //        // Call refund API
        //        var client = new RestClient(_baseUrl);
        //        var request = new RestRequest("/acceptance/void_refund/refund", Method.Post);

        //        var body = new
        //        {
        //            auth_token = authToken,
        //            transaction_id = int.Parse(transactionId),
        //            amount_cents = (int)amountCents
        //        };

        //        request.AddJsonBody(body);

        //        var response = await client.ExecuteAsync(request, cancellationToken);

        //        if (response.IsSuccessful && !string.IsNullOrEmpty(response.Content))
        //        {
        //            var refundResponse = JsonConvert.DeserializeObject<dynamic>(response.Content);

        //            _logger.LogInformation(
        //                "Refund successful for transaction {TransactionId}",
        //                transactionId);

        //            return new RefundPaymentResponse
        //            {
        //                Success = true,
        //                Message = "Refund processed successfully",
        //                RefundTransactionId = refundResponse?.id?.ToString(),
        //                RefundedAmount = amountCents / 100
        //            };
        //        }

        //        _logger.LogError("Refund failed: {Error}", response.ErrorMessage);
        //        return new RefundPaymentResponse
        //        {
        //            Success = false,
        //            Message = $"Refund failed: {response.ErrorMessage}"
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error processing refund for transaction {TransactionId}", transactionId);
        //        return new RefundPaymentResponse
        //        {
        //            Success = false,
        //            Message = $"Refund error: {ex.Message}"
        //        };
        //    }
        //}
        public async Task<RefundPaymentResponse> RefundPaymentAsync(
    string transactionId,
    decimal amountCents,
    CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Initiating refund for transaction {TransactionId}, Amount: {Amount} piasters",
                    transactionId, amountCents);

                // Authenticate
                var authToken = await AuthenticateAsync(cancellationToken);

                // Call refund API
                var client = new RestClient(_baseUrl);
                var request = new RestRequest("/acceptance/void_refund/refund", Method.Post);

                var body = new
                {
                    auth_token = authToken,
                    transaction_id = int.Parse(transactionId),
                    amount_cents = (int)amountCents
                };

                _logger.LogInformation(
                    "Refund request body: transaction_id={TransactionId}, amount_cents={AmountCents}",
                    transactionId, (int)amountCents);

                request.AddJsonBody(body);

                var response = await client.ExecuteAsync(request, cancellationToken);

                // ← الجزء الجديد: نطبع كل التفاصيل
                _logger.LogInformation(
                    "Paymob refund raw response => StatusCode: {StatusCode}, IsSuccessful: {IsSuccessful}, Content: {Content}, ErrorMessage: {ErrorMessage}",
                    response.StatusCode,
                    response.IsSuccessful,
                    response.Content ?? "(null)",
                    response.ErrorMessage ?? "(null)");

                if (response.IsSuccessful && !string.IsNullOrEmpty(response.Content))
                {
                    var refundResponse = JsonConvert.DeserializeObject<dynamic>(response.Content);

                    // ← نطبع الـ parsed response
                    _logger.LogInformation(
                        "Paymob refund parsed response: id={Id}, success={Success}, pending={Pending}",
                        (string?)refundResponse?.id?.ToString() ?? "(null)",
                        (string?)refundResponse?.success?.ToString() ?? "(null)",
                        (string?)refundResponse?.pending?.ToString() ?? "(null)");

                    // تحقق إن الـ refund نجح فعلاً
                    bool isSuccess = refundResponse?.success == true || refundResponse?.id != null;

                    if (!isSuccess)
                    {
                        _logger.LogWarning(
                            "Paymob refund returned 200 but success=false. Full response: {Content}",
                            response.Content);

                        return new RefundPaymentResponse
                        {
                            Success = false,
                            Message = $"Refund rejected by Paymob: {response.Content}"
                        };
                    }

                    _logger.LogInformation(
                        "Refund successful for transaction {TransactionId}, RefundId: {RefundId}",
                        transactionId, (string?)refundResponse?.id?.ToString());

                    return new RefundPaymentResponse
                    {
                        Success = true,
                        Message = "Refund processed successfully",
                        RefundTransactionId = refundResponse?.id?.ToString(),
                        RefundedAmount = amountCents / 100
                    };
                }

                // ← في حالة فشل الـ HTTP request
                _logger.LogError(
                    "Refund HTTP request failed => StatusCode: {StatusCode}, Content: {Content}, Error: {Error}",
                    response.StatusCode,
                    response.Content ?? "(null)",
                    response.ErrorMessage ?? "(null)");

                return new RefundPaymentResponse
                {
                    Success = false,
                    Message = $"Refund failed. StatusCode: {response.StatusCode}, Content: {response.Content ?? "(empty)"}"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Exception during refund for transaction {TransactionId}: {Message}",
                    transactionId, ex.Message);

                return new RefundPaymentResponse
                {
                    Success = false,
                    Message = $"Refund error: {ex.Message}"
                };
            }
        }

        #endregion

        #region Private Helper Methods

        private async Task<string> AuthenticateAsync(CancellationToken cancellationToken)
        {
            var client = new RestClient(_baseUrl);
            var request = new RestRequest("/auth/tokens", Method.Post);

            var body = new PaymobAuthRequest
            {
                api_key = _apiKey
            };

            request.AddJsonBody(body);

            var response = await client.ExecuteAsync(request, cancellationToken);

            if (!response.IsSuccessful || string.IsNullOrEmpty(response.Content))
            {
                _logger.LogError("Paymob authentication failed: {Error}", response.ErrorMessage);
                throw new DomainException("Payment gateway authentication failed");
            }

            var authResponse = JsonConvert.DeserializeObject<PaymobAuthResponse>(response.Content);
            return authResponse?.token ?? throw new DomainException("Invalid authentication response");
        }

        //private async Task<int> CreateOrderAsync(
        //    string authToken,
        //    decimal amountEGP,
        //    string merchantOrderId,
        //    CancellationToken cancellationToken)
        //{
        //    var client = new RestClient(_baseUrl);
        //    var request = new RestRequest("/ecommerce/orders", Method.Post);

        //    var amountCents = (int)(amountEGP * 100);

        //    var body = new PaymobOrderRequest
        //    {
        //        auth_token = authToken,
        //        delivery_needed = false,
        //        amount_cents = amountCents,
        //        currency = "EGP",
        //        items = new List<PaymobOrderItem>
        //        {
        //            new PaymobOrderItem
        //            {
        //                name = "Medical Consultation",
        //                amount_cents = amountCents,
        //                description = $"Appointment booking - {merchantOrderId}",
        //                quantity = 1
        //            }
        //        }
        //    };

        //    request.AddJsonBody(body);

        //    var response = await client.ExecuteAsync(request, cancellationToken);

        //    if (!response.IsSuccessful || string.IsNullOrEmpty(response.Content))
        //    {
        //        _logger.LogError("Paymob order creation failed: {Error}", response.ErrorMessage);
        //        throw new DomainException("Failed to create payment order");
        //    }

        //    var orderResponse = JsonConvert.DeserializeObject<PaymobOrderResponse>(response.Content);
        //    return orderResponse?.id ?? throw new DomainException("Invalid order response");
        //}
        private async Task<int> CreateOrderAsync(
            string authToken,
            decimal amountEGP,
            string merchantOrderId,  
            CancellationToken cancellationToken)
        {
            var client = new RestClient(_baseUrl);
            var request = new RestRequest("/ecommerce/orders", Method.Post);

            var amountCents = (int)(amountEGP * 100);

            var body = new
            {
                auth_token = authToken,
                delivery_needed = false,
                amount_cents = amountCents,
                currency = "EGP",
                merchant_order_id = merchantOrderId,   
                items = new List<object>
        {
            new
            {
                name = "Medical Consultation",
                amount_cents = amountCents,
                description = $"Appointment booking - {merchantOrderId}",
                quantity = 1
            }
        }
            };

            request.AddJsonBody(body);

            var response = await client.ExecuteAsync(request, cancellationToken);

            if (!response.IsSuccessful || string.IsNullOrEmpty(response.Content))
            {
                _logger.LogError("Paymob order creation failed: {Error} - Response: {Content}",
                    response.ErrorMessage, response.Content);
                throw new DomainException("Failed to create payment order");
            }

            var orderResponse = JsonConvert.DeserializeObject<PaymobOrderResponse>(response.Content);
            return orderResponse?.id ?? throw new DomainException("Invalid order response");
        }

        private async Task<string> CreatePaymentKeyAsync(
            string authToken,
            decimal amountEGP,
            int orderId,
            PaymentMethod paymentMethod,
            string email,
            string phone,
            string firstName,
            string lastName,
            CancellationToken cancellationToken)
        {
            var client = new RestClient(_baseUrl);
            var request = new RestRequest("/acceptance/payment_keys", Method.Post);

            var amountCents = (int)(amountEGP * 100);

            if (!_integrationIds.TryGetValue(paymentMethod, out var integrationId))
            {
                _logger.LogError("Payment method {Method} not found in integration IDs", paymentMethod);
                throw new DomainException($"Payment method {paymentMethod} not configured");
            }

            if (integrationId == 0)
            {
                _logger.LogError("Integration ID for {Method} is 0", paymentMethod);
                throw new DomainException($"Integration ID for {paymentMethod} is not set in configuration");
            }

            _logger.LogInformation(
                "Creating payment key with Integration ID: {IntegrationId} for {Method}",
                integrationId, paymentMethod);

            var body = new PaymobPaymentKeyRequest
            {
                auth_token = authToken,
                amount_cents = amountCents,
                expiration = 3600,
                order_id = orderId,
                currency = "EGP",
                integration_id = integrationId,
                billing_data = new PaymobBillingData
                {
                    email = email,
                    phone_number = phone,
                    first_name = firstName,
                    last_name = lastName,
                    apartment = "NA",
                    floor = "NA",
                    street = "NA",
                    building = "NA",
                    shipping_method = "NA",
                    postal_code = "NA",
                    city = "Cairo",
                    country = "EG",
                    state = "Cairo"
                }
            };

            //  Log the request body for debugging
            _logger.LogInformation(
                "Payment Key Request: Amount={Amount} cents, OrderId={OrderId}, IntegrationId={IntegrationId}",
                amountCents, orderId, integrationId);

            request.AddJsonBody(body);

            var response = await client.ExecuteAsync(request, cancellationToken);

            //  Enhanced error logging
            if (!response.IsSuccessful)
            {
                _logger.LogError(
                    "Paymob payment key creation failed. StatusCode: {StatusCode}, Content: {Content}, ErrorMessage: {Error}",
                    response.StatusCode,
                    response.Content,
                    response.ErrorMessage);

                throw new DomainException(
                    $"Failed to generate payment key. Status: {response.StatusCode}, Error: {response.ErrorMessage}");
            }

            if (string.IsNullOrEmpty(response.Content))
            {
                _logger.LogError("Paymob payment key response is empty");
                throw new DomainException("Invalid payment key response - empty content");
            }

            //  Log the response for debugging
            _logger.LogInformation("Payment Key Response: {Response}", response.Content);

            try
            {
                var keyResponse = JsonConvert.DeserializeObject<PaymobPaymentKeyResponse>(response.Content);

                if (keyResponse == null || string.IsNullOrEmpty(keyResponse.token))
                {
                    _logger.LogError(
                        "Payment key response is null or token is empty. Response: {Response}",
                        response.Content);
                    throw new DomainException("Invalid payment key response - no token");
                }

                _logger.LogInformation("Payment key generated successfully (length: {Length})", keyResponse.token.Length);

                return keyResponse.token;
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Failed to parse payment key response: {Content}", response.Content);
                throw new DomainException("Invalid payment key response format");
            }
        }

        private string ComputeHmac(string message, string secret)
        {
            var keyBytes = Encoding.UTF8.GetBytes(secret);
            var messageBytes = Encoding.UTF8.GetBytes(message);

            using var hmac = new HMACSHA512(keyBytes);
            var hashBytes = hmac.ComputeHash(messageBytes);

            return BitConverter.ToString(hashBytes).Replace("-", "").ToLower();
        }

        private string GetIframeId(PaymentMethod method)
        {
            if (_iframeIds.TryGetValue(method, out var iframeId) && !string.IsNullOrEmpty(iframeId))
            {
                return iframeId;
            }

            // Fallback to Card iframe
            _logger.LogWarning(
                "iFrame ID not configured for {Method}, using Card iframe as fallback",
                method);

            var cardIframe = _iframeIds[PaymentMethod.Card];

            if (string.IsNullOrEmpty(cardIframe))
            {
                throw new DomainException("Card iFrame ID not configured. Please check Paymob settings.");
            }

            return cardIframe;
        }

        #endregion
    }
}
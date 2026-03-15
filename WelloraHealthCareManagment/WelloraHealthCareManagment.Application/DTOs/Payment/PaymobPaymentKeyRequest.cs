using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class PaymobPaymentKeyRequest
    {
        public string auth_token { get; set; } = string.Empty;
        public decimal amount_cents { get; set; }
        public int expiration { get; set; } = 3600; // 1 hour
        public int order_id { get; set; }
        public PaymobBillingData billing_data { get; set; } = new();
        public string currency { get; set; } = "EGP";
        public int integration_id { get; set; }
    }

    public class PaymobBillingData
    {
        public string apartment { get; set; } = "NA";
        public string email { get; set; } = string.Empty;
        public string floor { get; set; } = "NA";
        public string first_name { get; set; } = string.Empty;
        public string street { get; set; } = "NA";
        public string building { get; set; } = "NA";
        public string phone_number { get; set; } = string.Empty;
        public string shipping_method { get; set; } = "NA";
        public string postal_code { get; set; } = "NA";
        public string city { get; set; } = "Cairo";
        public string country { get; set; } = "EG";
        public string last_name { get; set; } = string.Empty;
        public string state { get; set; } = "Cairo";
    }

    public class PaymobPaymentKeyResponse
    {
        public string token { get; set; } = string.Empty;
    }
}

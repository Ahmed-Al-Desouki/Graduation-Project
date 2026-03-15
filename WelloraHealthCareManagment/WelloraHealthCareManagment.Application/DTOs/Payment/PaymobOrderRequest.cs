using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class PaymobOrderRequest
    {
        public string auth_token { get; set; } = string.Empty;
        public bool delivery_needed { get; set; } = false;
        public decimal amount_cents { get; set; } // Amount in piasters (1 EGP = 100 piasters)
        public string currency { get; set; } = "EGP";
        public string merchant_order_id { get; set; } = string.Empty;
        public List<PaymobOrderItem> items { get; set; } = new();
    }

    public class PaymobOrderItem
    {
        public string name { get; set; } = string.Empty;
        public decimal amount_cents { get; set; }
        public string description { get; set; } = string.Empty;
        public int quantity { get; set; } = 1;
    }

    public class PaymobOrderResponse
    {
        public int id { get; set; } // Paymob Order ID
        public decimal amount_cents { get; set; }
        public string currency { get; set; } = string.Empty;
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    //public class PaymobCallbackRequest
    //{
    //    public PaymobCallbackObj obj { get; set; } = new();
    //    public string type { get; set; } = string.Empty;
    //}

    //public class PaymobCallbackObj
    //{
    //    public int id { get; set; } // Transaction ID
    //    public bool success { get; set; }
    //    public bool pending { get; set; }
    //    public decimal amount_cents { get; set; }
    //    public string currency { get; set; } = string.Empty;
    //    public int integration_id { get; set; }
    //    public bool is_refunded { get; set; }
    //    public bool is_refund { get; set; }
    //    public PaymobCallbackOrder order { get; set; } = new();
    //    public PaymobCallbackData data { get; set; } = new();
    //}


    //public class PaymobCallbackOrder
    //{
    //    public int id { get; set; } // Order ID
    //    public string merchant_order_id { get; set; } = string.Empty; // Our Appointment ID
    //}

    //public class PaymobCallbackData
    //{
    //    public string klass { get; set; } = string.Empty;
    //    public string message { get; set; } = string.Empty;
    //}

    public class PaymobCallbackRequest
    {
        public string type { get; set; } = string.Empty;
        public PaymobCallbackObj obj { get; set; } = new();
    }

    public class PaymobCallbackObj
    {
        public int id { get; set; }

        public long amount_cents { get; set; }

        public string currency { get; set; } = string.Empty;

        public bool success { get; set; }

        public bool pending { get; set; }

        public bool is_refunded { get; set; }

        public int integration_id { get; set; }

        public string created_at { get; set; } = string.Empty;

        public bool error_occured { get; set; }

        public bool has_parent_transaction { get; set; }

        public bool is_3d_secure { get; set; }

        public bool is_auth { get; set; }

        public bool is_capture { get; set; }

        public bool is_standalone_payment { get; set; }

        public bool is_voided { get; set; }

        public int owner { get; set; }

        public PaymobCallbackOrder order { get; set; } = new();

        public PaymobSourceData source_data { get; set; } = new();
    }

    public class PaymobCallbackOrder
    {
        public int id { get; set; }
        public string merchant_order_id { get; set; } = string.Empty;
    }

    public class PaymobSourceData
    {
        public string type { get; set; } = string.Empty;

        public string sub_type { get; set; } = string.Empty;

        public string pan { get; set; } = string.Empty;
    }
}

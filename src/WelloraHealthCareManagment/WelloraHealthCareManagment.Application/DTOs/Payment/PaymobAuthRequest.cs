using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class PaymobAuthRequest
    {
        public string api_key { get; set; } = string.Empty;
    }

    public class PaymobAuthResponse
    {
        public string token { get; set; } = string.Empty;
    }
}

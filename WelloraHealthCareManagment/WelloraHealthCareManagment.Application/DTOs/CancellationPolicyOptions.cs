using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs
{
    public class CancellationPolicyOptions
    {
        public const string SectionName = "CancellationPolicy";

        public decimal PatientRefundPercentage { get; set; } = 80;
        public decimal DoctorRefundPercentage { get; set; } = 100;
        public int MinimumCancellationHours { get; set; } = 24;
        public int MaxRefundDaysAfterPayment { get; set; } = 30;
        public int FreeCancellationGracePeriodHours { get; set; } = 1;
        public int RefundRetryAttempts { get; set; } = 3;
        public int RefundRetryDelayMs { get; set; } = 1000;
    }
}

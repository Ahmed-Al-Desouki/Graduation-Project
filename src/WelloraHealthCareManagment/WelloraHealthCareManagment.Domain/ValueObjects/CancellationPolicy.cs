using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.ValueObjects
{

    /// سياسة الإلغاء والاسترجاع

    public class CancellationPolicy
    {

        // REFUND PERCENTAGES

        /// نسبة الاسترجاع عند إلغاء المريض (80%)
        public const decimal PATIENT_CANCELLATION_REFUND_PERCENTAGE = 80m;
        /// نسبة الاسترجاع عند إلغاء الدكتور (100%)
        public const decimal DOCTOR_CANCELLATION_REFUND_PERCENTAGE = 100m;


        // TIME RESTRICTIONS

        /// الحد الأدنى للساعات قبل الموعد للإلغاء مع استرجاع (24 ساعة)
        public const int MINIMUM_CANCELLATION_HOURS = 24;
        /// الحد الأقصى للأيام بعد الدفع للاسترجاع (30 يوم)
        public const int MAX_REFUND_DAYS_AFTER_PAYMENT = 30;
        /// فترة الإلغاء المجاني بدون رسوم (1 ساعة بعد الحجز)
        public const int FREE_CANCELLATION_GRACE_PERIOD_HOURS = 1;


        // REFUND CALCULATION METHODS

        /// حساب مبلغ الاسترجاع بناءً على من قام بالإلغاء
        public static decimal CalculateRefundAmount(
            decimal paidAmount,
            CancelledBy cancelledBy)
        {
            var percentage = cancelledBy == CancelledBy.Patient
                ? PATIENT_CANCELLATION_REFUND_PERCENTAGE
                : DOCTOR_CANCELLATION_REFUND_PERCENTAGE;

            return Math.Round(paidAmount * (percentage / 100), 2);
        }

    
        /// الحصول على نسبة الاسترجاع بناءً على من قام بالإلغاء
        public static decimal GetRefundPercentage(CancelledBy cancelledBy)
        {
            return cancelledBy == CancelledBy.Patient
                ? PATIENT_CANCELLATION_REFUND_PERCENTAGE
                : DOCTOR_CANCELLATION_REFUND_PERCENTAGE;
        }


        // VALIDATION METHODS

        /// التحقق من إمكانية الإلغاء بناءً على التوقيت
        public static bool CanCancelWithRefund(
            DateTime appointmentDateTime,
            DateTime? paymentDate = null)
        {
            var now = DateTime.UtcNow;

            // Check minimum cancellation time (24 hours before appointment)
            var hoursUntilAppointment = (appointmentDateTime - now).TotalHours;
            if (hoursUntilAppointment < MINIMUM_CANCELLATION_HOURS)
                return false;

            // Check maximum refund period (30 days after payment)
            if (paymentDate.HasValue)
            {
                var daysSincePayment = (now - paymentDate.Value).TotalDays;
                if (daysSincePayment > MAX_REFUND_DAYS_AFTER_PAYMENT)
                    return false;
            }

            return true;
        }

    
        /// التحقق من فترة الإلغاء المجاني
        public static bool IsWithinFreeCalcellationPeriod(DateTime bookingDateTime)
        {
            var hoursSinceBooking = (DateTime.UtcNow - bookingDateTime).TotalHours;
            return hoursSinceBooking <= FREE_CANCELLATION_GRACE_PERIOD_HOURS;
        }

    
        /// الحصول على رسالة توضيحية عن سياسة الإلغاء  
        public static string GetCancellationPolicyMessage(CancelledBy cancelledBy)
        {
            var refundPercentage = GetRefundPercentage(cancelledBy);
            var initiator = cancelledBy == CancelledBy.Patient ? "المريض" : "الطبيب";

            return $"عند إلغاء الموعد من قبل {initiator}، سيتم استرجاع {refundPercentage}% من المبلغ المدفوع. " +
                   $"يجب الإلغاء قبل الموعد بـ {MINIMUM_CANCELLATION_HOURS} ساعة على الأقل للحصول على الاسترجاع.";
        }

    
        /// حساب الوقت المتبقي قبل نهاية فترة الإلغاء
        public static TimeSpan GetRemainingCancellationWindow(DateTime appointmentDateTime)
        {
            var lastCancellationTime = appointmentDateTime.AddHours(-MINIMUM_CANCELLATION_HOURS);
            var remainingTime = lastCancellationTime - DateTime.UtcNow;

            return remainingTime > TimeSpan.Zero ? remainingTime : TimeSpan.Zero;
        }
    }


    // CANCELLATION RESULT


    public class CancellationResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public decimal? RefundAmount { get; set; }
        public decimal? RefundPercentage { get; set; }
        public string? RefundTransactionId { get; set; }
        public bool RefundProcessed { get; set; }

        public static CancellationResult Failed(string message)
        {
            return new CancellationResult
            {
                Success = false,
                Message = message,
                RefundProcessed = false
            };
        }

        public static CancellationResult Succeeded(
            string message,
            decimal? refundAmount = null,
            decimal? refundPercentage = null,
            string? refundTransactionId = null)
        {
            return new CancellationResult
            {
                Success = true,
                Message = message,
                RefundAmount = refundAmount,
                RefundPercentage = refundPercentage,
                RefundTransactionId = refundTransactionId,
                RefundProcessed = refundAmount.HasValue
            };
        }
    }
}

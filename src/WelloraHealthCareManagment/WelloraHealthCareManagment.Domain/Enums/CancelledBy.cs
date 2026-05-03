namespace WelloraHealthCareManagement.Domain.Enums
{
    /// من قام بإلغاء الموعد
    public enum CancelledBy
    {
        /// المريض
        Patient = 1,

        /// الطبيب
        Doctor = 2,

        /// النظام (تلقائياً)
        System = 3
    }
}
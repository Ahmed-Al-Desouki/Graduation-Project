namespace WelloraHealthCareManagement.Domain.Enums
{
    /// أنواع الاستثناءات في الجدول
    public enum ExceptionType
    {
        /// إجازة (اليوم كامل مغلق)
        DayOff = 1,

        /// ساعات عمل مخصصة لهذا اليوم
        CustomHours = 2,

        /// طوارئ (إلغاء مفاجئ)
        Emergency = 3
    }
}
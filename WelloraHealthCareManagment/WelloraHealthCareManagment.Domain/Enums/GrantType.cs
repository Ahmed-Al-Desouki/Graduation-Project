namespace WelloraHealthCareManagement.Domain.Enums
{
    /// أنواع صلاحيات الوصول للتاريخ الطبي
    public enum GrantType
    {
        /// صلاحية مرتبطة بموعد محدد
        Appointment = 1,

        /// صلاحية مؤقتة (لفترة زمنية)
        Temporary = 2,

        /// صلاحية دائمة
        Permanent = 3
    }
}
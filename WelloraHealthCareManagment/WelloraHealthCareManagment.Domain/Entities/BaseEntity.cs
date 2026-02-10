namespace WelloraHealthCareManagement.Domain.Entities
{
    // Base class لكل الـ Entities
    // يحتوي على الخصائص المشتركة
     // تجنب تكرار الكود(DRY Principle)
     //تسهيل التتبع والـ Auditing
     //إمكانية إضافة خصائص مشتركة مستقبلاً(مثل CreatedBy, IsDeleted)
    public abstract class BaseEntity
    {
        public Guid Id { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}

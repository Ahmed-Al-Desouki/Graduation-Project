namespace HealthCare_.Models.OldModels.ReminderDTO
{
    public class IdempotencyRecord
    {
        public Guid Id { get; set; } = Guid.NewGuid(); // PK
        public string Key { get; set; } = null!;       // الـ IdempotencyKey اللي جاي من الـ Frontend
        public int? ReminderId { get; set; }           // لو نجح الـ Create
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

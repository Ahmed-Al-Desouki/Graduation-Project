//// File: Models/PatientModels/ReminderInstance.cs

//namespace HealthCare_.Models.PatientModels
//{
//    public class ReminderInstance
//    {
//        [Key]
//        [Required]
//        public int InstanceID { get; set; }

//        [Required]
//        public int ReminderID { get; set; }
//        [ForeignKey(nameof(ReminderID))]
//        public Reminder Reminder { get; set; } = null!;

//        [Required]
//        public DateTime DueDateTime { get; set; }

//        public Enums.ReminderStatus Status { get; set; } = Enums.ReminderStatus.Pending;

//        public DateTime? ConfirmedAt { get; set; }

//        public int? IntakeID { get; set; }
//        [ForeignKey(nameof(IntakeID))]
//        public MedicationsIntake? Intake { get; set; }

//        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
//    }
//}
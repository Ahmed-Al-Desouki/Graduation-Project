using HealthCare_.Models.AuthModels;
using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.SharedModels;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Models.Context
{
    public class HealthCarePlusContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        public HealthCarePlusContext(DbContextOptions<HealthCarePlusContext> options) : base(options) { }

        // DbSets for all entities
        public DbSet<Doctor> Doctors { get; set; }
        public DbSet<Patient> Patients { get; set; }
        public DbSet<DoctorSlot> DoctorSlots { get; set; }
        public DbSet<SessionType> SessionTypes { get; set; }
        public DbSet<MedicalHistory> MedicalHistories { get; set; }
        public DbSet<MedicalRecord> MedicalRecords { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<Prescription> Prescriptions { get; set; }
        public DbSet<PrescriptionMed> PrescriptionMeds { get; set; }
        public DbSet<MedicationsIntake> MedicationsIntakes { get; set; }
        public DbSet<Reminder> Reminders { get; set; }
        public DbSet<DoctorWeeklySchedule> DoctorWeeklySchedules { get; set; }
        public DbSet<DosingSchedule> DosingSchedules { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<ExternalFile> ExternalFiles { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<RevokedToken> RevokedTokens { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure ApplicationUser (Core user entity)
            modelBuilder.Entity<ApplicationUser>(entity =>
            {
                entity.ToTable("Users");
                entity.Property(u => u.Id).HasColumnName("UserID");
                entity.Property(u => u.FName).HasMaxLength(50);
                entity.Property(u => u.LName).HasMaxLength(50);
                entity.Property(u => u.Role).HasMaxLength(50)
                    .HasConversion<string>();
                entity.Property(u => u.Address).HasMaxLength(500);
                entity.Property(u => u.ProfileImagePath).HasMaxLength(500).HasDefaultValue("default.png");
                entity.Property(u => u.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                // MFA Properties
                entity.Property(u => u.TwoFactorEnabled).HasDefaultValue(false);
                entity.Property(u => u.AuthenticatorKey).HasMaxLength(500);
                entity.Property(u => u.RecoveryCodes).HasMaxLength(1000);
                // Passkey Properties
                entity.Property(u => u.PasskeyCredentialId).HasMaxLength(500);
                entity.Property(u => u.PasskeyPublicKey).HasMaxLength(1000);
                entity.HasIndex(u => u.PasskeyCredentialId).IsUnique().HasFilter("[PasskeyCredentialId] IS NOT NULL");
            });

            // Configure ApplicationRole (Custom role entity)
            modelBuilder.Entity<ApplicationRole>(entity =>
            {
                entity.ToTable("Roles");
                entity.Property(r => r.Id).HasColumnName("RoleID");
                entity.Property(r => r.Name).HasMaxLength(50).IsRequired();
                entity.Property(r => r.NormalizedName).HasMaxLength(50);
                entity.Property(r => r.Description).HasMaxLength(100);
                entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure UserSession (User session tracking)
            modelBuilder.Entity<UserSession>(entity =>
            {
                entity.HasKey(us => us.Id);
                entity.Property(us => us.UserId).IsRequired();
                entity.Property(us => us.DeviceInfo).HasMaxLength(500);
                entity.Property(us => us.IpAddress).HasMaxLength(100);
                entity.Property(us => us.RefreshTokenHash).HasMaxLength(450);
                entity.Property(us => us.EncryptedToken).HasMaxLength(500);
                entity.Property(us => us.Notes).HasMaxLength(300);
                entity.Property(us => us.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(us => us.ExpiresAt).IsRequired();
                entity.Property(us => us.LastActivity).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(us => us.User)
                    .WithMany()
                    .HasForeignKey(us => us.UserId)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(us => us.UserId);
            });

            // Configure RefreshToken (Authentication token management)
            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.HasKey(rt => rt.Id);
                entity.HasIndex(rt => rt.Token).IsUnique();
                entity.Property(rt => rt.Token).IsRequired().HasMaxLength(1000);
                entity.Property(rt => rt.JwtId).IsRequired().HasMaxLength(500);
                entity.Property(rt => rt.DeviceInfo).HasMaxLength(500);
                entity.Property(rt => rt.IpAddress).HasMaxLength(100);
                entity.Property(rt => rt.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(rt => rt.Expires).IsRequired();
                entity.HasOne(rt => rt.User)
                    .WithMany()
                    .HasForeignKey(rt => rt.UserId)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(rt => rt.UserSession)
                    .WithMany()
                    .HasForeignKey(rt => rt.UserSessionId)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasOne(rt => rt.ReplacedBy)
                    .WithMany()
                    .HasForeignKey(rt => rt.ReplacedById)
                    .OnDelete(DeleteBehavior.NoAction);
                entity.HasIndex(rt => rt.JwtId);
            });

            // Configure RevokedToken (Track revoked JWTs)
            modelBuilder.Entity<RevokedToken>(entity =>
            {
                entity.HasKey(rt => rt.Id);
                entity.HasIndex(rt => rt.Jti);
                entity.Property(rt => rt.Jti).IsRequired().HasMaxLength(500);
                entity.Property(rt => rt.Expires).IsRequired();
                entity.Property(rt => rt.RevokedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure Doctor (Doctor profile)
            modelBuilder.Entity<Doctor>(entity =>
            {
                entity.HasKey(d => d.DoctorID);
                entity.Property(d => d.Specialization).HasMaxLength(100).IsRequired();
                entity.Property(d => d.YearsOfExperience).HasDefaultValue(0);
                entity.Property(d => d.ConsultationFee).HasColumnType("decimal(18,2)");
                entity.Property(d => d.AverageRating).HasColumnType("float").HasDefaultValue(0);
                entity.Property(d => d.Description).HasMaxLength(500);
                entity.Property(d => d.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(d => d.User)
                    .WithOne(u => u.Doctor)
                    .HasForeignKey<Doctor>(d => d.UserID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(d => d.UserID).IsUnique();
            });

            // Configure Patient (Patient profile)
            modelBuilder.Entity<Patient>(entity =>
            {
                entity.HasKey(p => p.PatientID);
                entity.Property(p => p.Gender).HasMaxLength(10).IsRequired();
                entity.Property(p => p.CurrentLocation).HasMaxLength(200);
                entity.Property(p => p.DateOfBirth).IsRequired();
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(p => p.User)
                    .WithOne(u => u.Patient)
                    .HasForeignKey<Patient>(p => p.UserID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(p => p.UserID).IsUnique();
            });

            // Configure DoctorSlot (Doctor's availability slots)
            modelBuilder.Entity<DoctorSlot>(entity =>
            {
                entity.HasKey(ds => ds.SlotID);
                entity.Property(ds => ds.SlotDate).IsRequired();
                entity.Property(ds => ds.Duration).HasDefaultValue(30);
                entity.Property(ds => ds.IsBooked).HasDefaultValue(false);
                entity.Property(ds => ds.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(ds => ds.Doctor)
                    .WithMany(d => d.Slots)
                    .HasForeignKey(ds => ds.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(ds => ds.Appointment)
                    .WithOne(a => a.Slot)
                    .HasForeignKey<Appointment>(a => a.SlotID)
                    .OnDelete(DeleteBehavior.Restrict);
                entity.HasIndex(ds => new { ds.DoctorID, ds.SlotDate });
            });

            // Configure SessionType (Doctor's session types)
            modelBuilder.Entity<SessionType>(entity =>
            {
                entity.HasKey(st => st.SessionTypeID);
                entity.Property(st => st.Name).HasMaxLength(100).IsRequired();
                entity.Property(st => st.Duration).IsRequired();
                entity.Property(st => st.Price).HasColumnType("decimal(18,2)").IsRequired();
                entity.Property(st => st.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(st => st.Doctor)
                    .WithMany(d => d.SessionTypes)
                    .HasForeignKey(st => st.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(st => st.DoctorID);
            });

            // Configure DoctorWeeklySchedule (Doctor's weekly availability)
            modelBuilder.Entity<DoctorWeeklySchedule>(entity =>
            {
                entity.HasKey(dws => dws.ScheduleID);
                entity.Property(dws => dws.DayOfWeek).HasMaxLength(20).IsRequired();
                entity.Property(dws => dws.StartTime).IsRequired();
                entity.Property(dws => dws.EndTime).IsRequired();
                entity.Property(dws => dws.Duration).HasDefaultValue(30);
                entity.Property(dws => dws.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(dws => dws.Doctor)
                    .WithMany(d => d.WeeklySchedules)
                    .HasForeignKey(dws => dws.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(dws => new { dws.DoctorID, dws.DayOfWeek });
            });

            // Configure MedicalHistory (Patient's medical history)
            modelBuilder.Entity<MedicalHistory>(entity =>
            {
                entity.HasKey(mh => mh.HistoryID);
                entity.Property(mh => mh.BloodType).HasMaxLength(10);
                entity.Property(mh => mh.Allergies).HasMaxLength(500);
                entity.Property(mh => mh.ChronicConditions).HasMaxLength(500);
                entity.Property(mh => mh.Height).HasColumnType("float");
                entity.Property(mh => mh.Weight).HasColumnType("float");
                entity.Property(mh => mh.FilePath).HasMaxLength(500);
                entity.Property(mh => mh.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(mh => mh.Patient)
                    .WithMany(pt => pt.MedicalHistories)
                    .HasForeignKey(mh => mh.PatientID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(mh => mh.PatientID);
            });

            // Configure MedicalRecord (Doctor's medical records for patient)
            modelBuilder.Entity<MedicalRecord>(entity =>
            {
                entity.HasKey(mr => mr.RecordID);
                entity.Property(mr => mr.Diagnosis).HasMaxLength(500);
                entity.Property(mr => mr.Symptoms).HasMaxLength(500);
                entity.Property(mr => mr.Notes).HasMaxLength(1000);
                entity.Property(mr => mr.CurrentStatus).HasMaxLength(100);
                entity.Property(mr => mr.FilePath).HasMaxLength(500);
                entity.Property(mr => mr.VisitDate).IsRequired();
                entity.Property(mr => mr.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(mr => mr.MedicalHistory)
                    .WithMany(mh => mh.MedicalRecords)
                    .HasForeignKey(mr => mr.HistoryID)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired();
                entity.HasOne(mr => mr.Doctor)
                    .WithMany(d => d.MedicalRecords)
                    .HasForeignKey(mr => mr.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(mr => new { mr.HistoryID, mr.DoctorID });
            });

            // Configure Appointment (Patient-Doctor appointments)
            modelBuilder.Entity<Appointment>(entity =>
            {
                entity.HasKey(a => a.AppointmentID);
                entity.Property(a => a.Symptoms).HasMaxLength(500);
                entity.Property(a => a.Status).HasMaxLength(50).IsRequired();
                entity.Property(a => a.Type).HasMaxLength(50);
                entity.Property(a => a.EmergencyLevel).HasMaxLength(50);
                entity.Property(a => a.Duration).IsRequired();
                entity.Property(a => a.AppointmentDate).IsRequired();
                entity.Property(a => a.BookingDate).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(a => a.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(a => a.Patient)
                    .WithMany(pt => pt.Appointments)
                    .HasForeignKey(a => a.PatientID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(a => a.Doctor)
                    .WithMany(d => d.Appointments)
                    .HasForeignKey(a => a.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(a => a.Slot)
                    .WithOne(ds => ds.Appointment)
                    .HasForeignKey<Appointment>(a => a.SlotID)
                    .OnDelete(DeleteBehavior.Restrict);
                entity.HasIndex(a => new { a.PatientID, a.DoctorID, a.AppointmentDate });
            });

            // Configure Prescription (Doctor prescriptions for patients)
            modelBuilder.Entity<Prescription>(entity =>
            {
                entity.HasKey(p => p.PrescriptionID);
                entity.Property(p => p.GeneralInstructions).HasMaxLength(500);
                entity.Property(p => p.PrescriptionDate).IsRequired();
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(p => p.Patient)
                    .WithMany(pt => pt.Prescriptions)
                    .HasForeignKey(p => p.PatientID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(p => p.Doctor)
                    .WithMany(d => d.Prescriptions)
                    .HasForeignKey(p => p.DoctorID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasIndex(p => new { p.PatientID, p.DoctorID });
            });

            // Configure PrescriptionMed (Medications in a prescription)
            modelBuilder.Entity<PrescriptionMed>(entity =>
            {
                entity.HasKey(pm => pm.ID);
                entity.Property(pm => pm.MedicationName).HasMaxLength(100).IsRequired();
                entity.Property(pm => pm.Dosage).HasMaxLength(50);
                entity.Property(pm => pm.Instructions).HasMaxLength(500);
                entity.Property(pm => pm.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(pm => pm.Prescription)
                    .WithMany(p => p.Medications)
                    .HasForeignKey(pm => pm.PrescriptionID)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired();
                entity.HasIndex(pm => pm.PrescriptionID);
            });

            // Configure DosingSchedule (Medication dosing times)
            modelBuilder.Entity<DosingSchedule>(entity =>
            {
                entity.HasKey(ds => ds.DosingScheduleID);
                entity.Property(ds => ds.DailyTime).IsRequired();
                entity.HasOne(ds => ds.PrescriptionMed)
                    .WithMany(pm => pm.DosingSchedules)
                    .HasForeignKey(ds => ds.PrescriptionMedID)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired();
                entity.HasIndex(ds => ds.PrescriptionMedID);
            });

            // Configure MedicationsIntake (Tracking medication intake)
            modelBuilder.Entity<MedicationsIntake>(entity =>
            {
                entity.HasKey(mi => mi.IntakeID);
                entity.Property(mi => mi.DateTaken).IsRequired();
                entity.Property(mi => mi.Status).IsRequired()
                    .HasConversion<string>();
                entity.Property(mi => mi.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(mi => mi.PrescriptionMed)
                    .WithMany(pm => pm.MedicationsIntakes)
                    .HasForeignKey(mi => mi.PrescriptionMedID)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired();
                entity.HasIndex(mi => mi.PrescriptionMedID);
            });

            // Configure Reminder (Appointment and medication reminders)
            modelBuilder.Entity<Reminder>(entity =>
            {
                entity.HasKey(r => r.ReminderID);
                entity.Property(r => r.Type).IsRequired()
                    .HasConversion<string>();
                entity.Property(r => r.ReminderDateTime).IsRequired();
                entity.Property(r => r.Message).HasMaxLength(500);
                entity.Property(r => r.Status).IsRequired()
                    .HasConversion<string>();
                entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(r => r.PrescriptionMed)
                    .WithMany(pm => pm.Reminders)
                    .HasForeignKey(r => r.PrescriptionMedID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasOne(r => r.Appointment)
                    .WithMany(a => a.Reminders)
                    .HasForeignKey(r => r.AppointmentID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasIndex(r => new { r.PrescriptionMedID, r.AppointmentID });
            });

            // Configure Review (User reviews for appointments)
            modelBuilder.Entity<Review>(entity =>
            {
                entity.HasKey(r => r.ReviewID);
                entity.Property(r => r.TargetType).HasMaxLength(50).IsRequired();
                entity.Property(r => r.Rating).HasColumnType("float").IsRequired();
                entity.Property(r => r.Comment).HasMaxLength(1000);
                entity.Property(r => r.FilePath).HasMaxLength(500);
                entity.Property(r => r.ReviewDate).IsRequired();
                entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.HasOne(r => r.User)
                    .WithMany(u => u.Reviews)
                    .HasForeignKey(r => r.UserID)
                    .OnDelete(DeleteBehavior.Restrict)
                    .IsRequired();
                entity.HasOne(r => r.Appointment)
                    .WithMany(a => a.Reviews)
                    .HasForeignKey(r => r.AppointmentID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasIndex(r => new { r.UserID, r.AppointmentID });
            });

            // Configure ExternalFile (Files for doctors, patients, or medical history)
            modelBuilder.Entity<ExternalFile>(entity =>
            {
                entity.HasKey(f => f.FileID);
                entity.Property(f => f.FileUrl).IsRequired().HasMaxLength(500);
                entity.Property(f => f.PublicId).IsRequired().HasMaxLength(200);
                entity.Property(f => f.FileType).HasMaxLength(100);
                entity.Property(f => f.FileSize).IsRequired();
                entity.Property(f => f.UploadedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(f => f.Category).IsRequired()
                    .HasConversion<string>();
                entity.HasOne(f => f.Doctor)
                    .WithMany(d => d.Files)
                    .HasForeignKey(f => f.DoctorID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasOne(f => f.Patient)
                    .WithMany()
                    .HasForeignKey(f => f.PatientID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasOne(f => f.MedicalHistory)
                    .WithMany(mh => mh.Files)
                    .HasForeignKey(f => f.MedicalHistoryID)
                    .OnDelete(DeleteBehavior.SetNull);
                entity.HasIndex(f => new { f.DoctorID, f.PatientID, f.MedicalHistoryID });
            });
        }
    }
}
using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.DTOs.Email;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using HealthCare_.Models.sharedModels.Reviews;
using HealthCare_.Models.V2;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Infrastructure.Data.Configurations;
using WelloraHealthCareManagement.Infrastructure.Data.Interceptors;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.Entities.sharedModels;
using WelloraHealthCareManagment.Infrastructure.Data.Configurations;
using WelloraHealthCareManagment.Domain.Enums;


namespace WelloraHealthCareManagment.API.Context
{
    public class HealthCarePlusContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        public HealthCarePlusContext(DbContextOptions<HealthCarePlusContext> options) : base(options) { }

        // DbSets
        public DbSet<Doctor> Doctors { get; set; } = null!;
        public DbSet<Patient> Patients { get; set; } = null!;
        public DbSet<MedicalHistory> MedicalHistories { get; set; } = null!;
        public DbSet<MedicationsIntake> MedicationsIntakes { get; set; } = null!;
        public DbSet<DosingSchedule> DosingSchedules { get; set; } = null!;
        public DbSet<Review> Reviews { get; set; } = null!;
        public DbSet<ExternalFile> ExternalFiles { get; set; } = null!;
        public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
        public DbSet<HealthCare_.Models.DTOs.AuthModels.RevokedToken> RevokedTokens { get; set; } = null!;
        public DbSet<UserSession> UserSessions { get; set; } = null!;
        public DbSet<EmailOTP> EmailOtps { get; set; } = null!;
        public DbSet<Surgery> Surgeries { get; set; }
        public DbSet<FamilyHistoryEntry> FamilyHistoryEntries { get; set; }
        public DbSet<SocialHistory> SocialHistories { get; set; }
        public DbSet<PatientSelfMedication> PatientSelfMedications { get; set; }
        public DbSet<ReminderV2> ReminderV2s { get; set; }
        public DbSet<ReminderOccurrenceLog> ReminderOccurrenceLogs { get; set; }
        public DbSet<ReminderOccurrencesCache> ReminderOccurrencesCache { get; set; }
        public DbSet<PatientDevice> PatientDevices { get; set; }

        // === Booking System DbSets === دي جداول نظام الحجوزات الجديد
        public DbSet<DoctorScheduleTemplate> DoctorScheduleTemplates => Set<DoctorScheduleTemplate>();
        public DbSet<ScheduleTimeRange> ScheduleTimeRanges => Set<ScheduleTimeRange>();
        public DbSet<ScheduleException> ScheduleExceptions => Set<ScheduleException>();
        public DbSet<TimeSlot> TimeSlots => Set<TimeSlot>();
        public DbSet<Appointment> Appointments => Set<Appointment>();
        public DbSet<AppointmentMedicalRecord> AppointmentMedicalRecords => Set<AppointmentMedicalRecord>();
        public DbSet<Prescription> Prescriptions => Set<Prescription>();
        public DbSet<PrescriptionItem> PrescriptionItems => Set<PrescriptionItem>();
        public DbSet<MedicalHistoryAccessGrant> MedicalHistoryAccessGrants => Set<MedicalHistoryAccessGrant>();
        public DbSet<MedicalHistoryAccessLog> MedicalHistoryAccessLogs => Set<MedicalHistoryAccessLog>();
        public DbSet<Payment> Payments { get; set; }
        public DbSet<DoctorAchievement> DoctorAchievements { get; set; }
        public DbSet<DoctorVerification> DoctorVerifications { get; set; }

        //public DbSet<AppointmentNotification> AppointmentNotifications => Set<AppointmentNotification>();


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.AddInterceptors(new UpdateTimestampsInterceptor());
        }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Apply all configurations
            modelBuilder.ApplyConfiguration(new DoctorScheduleTemplateConfiguration());
            modelBuilder.ApplyConfiguration(new ScheduleTimeRangeConfiguration());
            modelBuilder.ApplyConfiguration(new ScheduleExceptionConfiguration());
            modelBuilder.ApplyConfiguration(new TimeSlotConfiguration());
            modelBuilder.ApplyConfiguration(new AppointmentConfiguration());
            modelBuilder.ApplyConfiguration(new AppointmentMedicalRecordConfiguration());
            modelBuilder.ApplyConfiguration(new PrescriptionConfiguration());
            modelBuilder.ApplyConfiguration(new PrescriptionItemConfiguration());
            modelBuilder.ApplyConfiguration(new MedicalHistoryAccessGrantConfiguration());
            modelBuilder.ApplyConfiguration(new MedicalHistoryAccessLogConfiguration());
            modelBuilder.ApplyConfiguration(new PaymentConfiguration());

            // ─────────────────────── ApplicationUser ───────────────────────
            modelBuilder.Entity<ApplicationUser>(entity =>
            {
                entity.ToTable("Users");
                entity.Property(u => u.Id).HasColumnName("UserID");
                entity.Property(u => u.FullName).HasMaxLength(100).IsRequired();
                entity.Property(u => u.Role).HasMaxLength(50).IsRequired();
                entity.Property(u => u.Address).HasMaxLength(500);
                entity.Property(u => u.CreatedAt).HasDefaultValueSql("GETUTCDATE()").IsRequired();
                entity.Property(u => u.UpdatedAt).IsConcurrencyToken();
                entity.Property(u => u.TwoFactorEnabled).HasDefaultValue(false);
                entity.Property(u => u.PasskeyCredentialId).HasMaxLength(500);
                entity.Property(u => u.PasskeyPublicKey).HasMaxLength(2000);

                entity.HasOne(u => u.ProfileImagePath)
                      .WithMany()
                      .HasForeignKey(u => u.ProfileImageId)
                      .OnDelete(DeleteBehavior.SetNull)
                      .IsRequired(false);

                entity.HasIndex(u => u.PasskeyCredentialId)
                      .IsUnique()
                      .HasFilter("[PasskeyCredentialId] IS NOT NULL");
            });

            // ─────────────────────── ApplicationRole ───────────────────────
            modelBuilder.Entity<ApplicationRole>(entity =>
            {
                entity.ToTable("Roles");
                entity.Property(r => r.Id).HasColumnName("RoleID");
                entity.Property(r => r.Name).HasMaxLength(50).IsRequired();
                entity.Property(r => r.Description).HasMaxLength(100);
                entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // ─────────────────────── UserSession ───────────────────────
            modelBuilder.Entity<UserSession>(entity =>
            {
                entity.HasKey(us => us.Id);
                entity.Property(us => us.UserId).IsRequired();
                entity.Property(us => us.DeviceInfo).HasMaxLength(500);
                entity.Property(us => us.IpAddress).HasMaxLength(100);
                entity.Property(us => us.EncryptedToken).HasMaxLength(500);
                entity.Property(us => us.Salt).HasMaxLength(500);
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


            // ─────────────────────── RefreshToken ───────────────────────
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

                entity.HasIndex(rt => rt.JwtId);
            });

            // ─────────────────────── RevokedToken ───────────────────────
            modelBuilder.Entity<HealthCare_.Models.DTOs.AuthModels.RevokedToken>(entity =>
            {
                entity.HasKey(rt => rt.Id);
                entity.HasIndex(rt => rt.Jti).IsUnique();
                entity.Property(rt => rt.Jti).IsRequired().HasMaxLength(500);
                entity.Property(rt => rt.Expires).IsRequired();
                entity.Property(rt => rt.RevokedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // ─────────────────────── Patient (1:1 with User) ───────────────────────
            modelBuilder.Entity<Patient>(entity =>
            {
                entity.HasKey(p => p.PatientID);
                entity.Property(p => p.PatientID).ValueGeneratedNever();
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(p => p.UpdatedAt).ValueGeneratedOnUpdate();

                entity.HasOne(p => p.User)
                      .WithOne(u => u.Patient)
                      .HasForeignKey<Patient>(p => p.PatientID)
                      .OnDelete(DeleteBehavior.Restrict)
                      .IsRequired();

                entity.HasOne(p => p.MedicalHistory)
                      .WithOne(mh => mh.Patient)
                      .HasForeignKey<MedicalHistory>(mh => mh.PatientID)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(p => p.PatientID).IsUnique();
            });

            modelBuilder.Entity<PrescriptionItem>()
            .HasOne(pi => pi.Prescription)
            .WithMany(p => p.Items)
            .HasForeignKey(pi => pi.PrescriptionId)
            .OnDelete(DeleteBehavior.Cascade);

            // ─────────────────────── Doctor (1:1 with User) ───────────────────────
            modelBuilder.Entity<Doctor>(entity =>
            {
                entity.HasKey(d => d.DoctorId);
                entity.Property(d => d.DoctorId).ValueGeneratedNever();
                entity.Property(d => d.Specialization).HasMaxLength(100).IsRequired();
                entity.Property(d => d.YearsOfExperience).HasDefaultValue(0);
                entity.Property(d => d.ConsultationFee).HasColumnType("decimal(18,2)");
                entity.Property(d => d.AverageRating).HasColumnType("float").HasDefaultValue(0);
                entity.Property(d => d.Description).HasMaxLength(500);
                entity.Property(d => d.CreatedAt).HasDefaultValueSql("GETUTCDATE()");


                entity.Property(d => d.ConsultationFee)
                    .HasColumnType("decimal(18,2)")
                    .HasDefaultValue(200)
                    .IsRequired();

                entity.HasOne(d => d.User)
                      .WithOne(u => u.Doctor)
                      .HasForeignKey<Doctor>(d => d.DoctorId)
                      .OnDelete(DeleteBehavior.Restrict)
                      .IsRequired();

                entity.HasIndex(d => d.DoctorId).IsUnique();
            });

            // ─────────────────────── DoctorSlot ───────────────────────
            //modelBuilder.Entity<DoctorSlot>(entity =>
            //{
            //    entity.HasKey(ds => ds.SlotID);
            //    entity.Property(ds => ds.SlotDate).IsRequired();
            //    entity.Property(ds => ds.Duration).HasDefaultValue(30);
            //    entity.Property(ds => ds.IsBooked).HasDefaultValue(false);
            //    entity.Property(ds => ds.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(ds => ds.Doctor)
            //          .WithMany(d => d.Slots)
            //          .HasForeignKey(ds => ds.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasIndex(ds => new { ds.DoctorID, ds.SlotDate });
            //});

            //// ─────────────────────── SessionType ───────────────────────
            //modelBuilder.Entity<SessionType>(entity =>
            //{
            //    entity.HasKey(st => st.SessionTypeID);
            //    entity.Property(st => st.Name).HasMaxLength(100).IsRequired();
            //    entity.Property(st => st.Duration).IsRequired();
            //    entity.Property(st => st.Price).HasColumnType("decimal(18,2)").IsRequired();
            //    entity.Property(st => st.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(st => st.Doctor)
            //          .WithMany(d => d.SessionTypes)
            //          .HasForeignKey(st => st.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasIndex(st => st.DoctorID);
            //});

            //// ─────────────────────── DoctorWeeklySchedule ───────────────────────
            //modelBuilder.Entity<DoctorWeeklySchedule>(entity =>
            //{
            //    entity.HasKey(dws => dws.ScheduleID);
            //    entity.Property(dws => dws.DayOfWeek).HasMaxLength(20).IsRequired();
            //    entity.Property(dws => dws.StartTime).IsRequired();
            //    entity.Property(dws => dws.EndTime).IsRequired();
            //    entity.Property(dws => dws.Duration).HasDefaultValue(30);
            //    entity.Property(dws => dws.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(dws => dws.Doctor)
            //          .WithMany(d => d.WeeklySchedules)
            //          .HasForeignKey(dws => dws.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasIndex(dws => new { dws.DoctorID, dws.DayOfWeek });
            //});

            // ─────────────────────── MedicalHistory ───────────────────────
            modelBuilder.Entity<MedicalHistory>(entity =>
            {
                entity.HasKey(mh => mh.HistoryID);
                entity.Property(mh => mh.PatientID).IsRequired();

                entity.Property(mh => mh.BloodType).HasMaxLength(10);
                entity.Property(mh => mh.AllergiesJson).HasColumnType("nvarchar(max)");
                entity.Property(mh => mh.ChronicConditionsJson).HasColumnType("nvarchar(max)");
                entity.Property(mh => mh.Height).HasColumnType("float");
                entity.Property(mh => mh.Weight).HasColumnType("float");
                entity.Property(mh => mh.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(mh => mh.UpdatedAt).ValueGeneratedOnUpdate();

                entity.HasOne(mh => mh.Patient)
                      .WithOne(p => p.MedicalHistory)
                      .HasForeignKey<MedicalHistory>(mh => mh.PatientID)
                      .OnDelete(DeleteBehavior.Cascade)  // ← دي الوحيدة اللي فيها Cascade وهي منطقية
                      .IsRequired();

                entity.HasIndex(mh => mh.PatientID).IsUnique();
            });
            // ─────────────────────── SelfMedication ───────────────────────
            modelBuilder.Entity<PatientSelfMedication>(entity =>
            {
                entity.HasKey(psm => psm.ID);

                entity.HasOne(psm => psm.MedicalHistory)
                      .WithMany(mh => mh.SelfMedications)
                      .HasForeignKey(psm => psm.HistoryID)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(psm => psm.Patient)
                      .WithMany(p => p.SelfMedications)
                      .HasForeignKey(psm => psm.PatientID)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(psm => psm.HistoryID);
                entity.HasIndex(psm => psm.PatientID);
            });
            // ─────────────────────── MedicalRecord ───────────────────────
            //modelBuilder.Entity<MedicalRecord>(entity =>
            //{
            //    entity.HasKey(mr => mr.RecordID);
            //    entity.Property(mr => mr.Diagnosis).HasMaxLength(500);
            //    entity.Property(mr => mr.Symptoms).HasMaxLength(500);
            //    entity.Property(mr => mr.Notes).HasMaxLength(1000);
            //    entity.Property(mr => mr.CurrentStatus).HasMaxLength(100);
            //    entity.Property(mr => mr.FilePath).HasMaxLength(500);
            //    entity.Property(mr => mr.VisitDate).IsRequired();
            //    entity.Property(mr => mr.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(mr => mr.MedicalHistory)
            //          .WithMany(mh => mh.MedicalRecords)
            //          .HasForeignKey(mr => mr.HistoryID)
            //          .OnDelete(DeleteBehavior.Cascade)
            //          .IsRequired();

            //    entity.HasOne(mr => mr.Doctor)
            //          .WithMany(d => d.MedicalRecords)
            //          .HasForeignKey(mr => mr.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasIndex(mr => new { mr.HistoryID, mr.DoctorID });
            //});

            // ─────────────────────── Appointment ───────────────────────
            //modelBuilder.Entity<Appointment>(entity =>
            //{
            //    entity.HasKey(a => a.AppointmentID);
            //    entity.Property(a => a.Symptoms).HasMaxLength(500);
            //    entity.Property(a => a.Status).HasMaxLength(50).IsRequired();
            //    entity.Property(a => a.Type).HasMaxLength(50);
            //    entity.Property(a => a.EmergencyLevel).HasMaxLength(50);
            //    entity.Property(a => a.Duration).IsRequired();
            //    entity.Property(a => a.AppointmentDate).IsRequired();
            //    entity.Property(a => a.BookingDate).HasDefaultValueSql("GETUTCDATE()");
            //    entity.Property(a => a.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(a => a.Patient)
            //          .WithMany(p => p.Appointments)
            //          .HasForeignKey(a => a.PatientID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasOne(a => a.Doctor)
            //          .WithMany(d => d.Appointments)
            //          .HasForeignKey(a => a.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasOne(a => a.Slot)
            //          .WithOne(ds => ds.Appointment)
            //          .HasForeignKey<Appointment>(a => a.SlotID)
            //          .OnDelete(DeleteBehavior.Restrict);

            //    entity.HasIndex(a => new { a.PatientID, a.DoctorID, a.AppointmentDate });
            //});

            //// ─────────────────────── Prescription ───────────────────────
            //modelBuilder.Entity<Prescription>(entity =>
            //{
            //    entity.HasKey(p => p.PrescriptionID);
            //    entity.Property(p => p.GeneralInstructions).HasMaxLength(500);
            //    entity.Property(p => p.PrescriptionDate).IsRequired();
            //    entity.Property(p => p.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(p => p.Patient)
            //          .WithMany(pt => pt.Prescriptions)
            //          .HasForeignKey(p => p.PatientID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasOne(p => p.Doctor)
            //          .WithMany(d => d.Prescriptions)
            //          .HasForeignKey(p => p.DoctorID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasIndex(p => new { p.PatientID, p.DoctorID });
            //});

            //// ─────────────────────── PrescriptionMed ───────────────────────
            //modelBuilder.Entity<PrescriptionMed>(entity =>
            //{
            //    entity.HasKey(pm => pm.ID);
            //    entity.Property(pm => pm.MedicationName).HasMaxLength(100).IsRequired();
            //    entity.Property(pm => pm.Dosage).HasMaxLength(50);
            //    entity.Property(pm => pm.Instructions).HasMaxLength(500);
            //    entity.Property(pm => pm.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(pm => pm.Prescription)
            //          .WithMany(p => p.Medications)
            //          .HasForeignKey(pm => pm.PrescriptionID)
            //          .OnDelete(DeleteBehavior.Cascade)
            //          .IsRequired();

            //    entity.HasIndex(pm => pm.PrescriptionID);
            //});

            // ─────────────────────── DosingSchedule ───────────────────────
            modelBuilder.Entity<DosingSchedule>(entity =>
            {
                entity.HasKey(ds => ds.DosingScheduleID);
                entity.Property(ds => ds.DailyTime).IsRequired();

                //entity.HasOne(ds => ds.PrescriptionMed)
                //      .WithMany(pm => pm.DosingSchedules)
                //      .HasForeignKey(ds => ds.PrescriptionMedID)
                //      .OnDelete(DeleteBehavior.Cascade)
                //      .IsRequired();

                entity.HasIndex(ds => ds.PrescriptionMedID);
            });

            // ─────────────────────── MedicationsIntake ───────────────────────
            modelBuilder.Entity<MedicationsIntake>(entity =>
            {
                entity.HasKey(mi => mi.IntakeID);
                entity.Property(mi => mi.DateTaken).IsRequired();
                entity.Property(mi => mi.Status).IsRequired().HasConversion<string>();
                entity.Property(mi => mi.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                //entity.HasOne(mi => mi.PrescriptionMed)
                //      .WithMany(pm => pm.MedicationsIntakes)
                //      .HasForeignKey(mi => mi.PrescriptionMedID)
                //      .OnDelete(DeleteBehavior.Cascade)
                //      .IsRequired();

                //entity.HasOne(mi => mi.ReminderInstance)
                //      .WithOne(ri => ri.Intake)
                //      .HasForeignKey<MedicationsIntake>(mi => mi.ReminderInstanceID)
                //      .OnDelete(DeleteBehavior.SetNull)
                //      .IsRequired(false);

                entity.HasIndex(mi => mi.PrescriptionMedID);
                entity.HasIndex(mi => mi.ReminderInstanceID);
            });

            // ─────────────────────── Reminder ───────────────────────
            //modelBuilder.Entity<Reminder>(entity =>
            //{
            //    entity.HasKey(r => r.ReminderID);
            //    entity.Property(r => r.Type).IsRequired().HasConversion<string>();
            //    entity.Property(r => r.Name).HasMaxLength(100);
            //    entity.Property(r => r.StartDate).IsRequired();
            //    entity.Property(r => r.EndDate);
            //    entity.Property(r => r.Frequency).IsRequired().HasConversion<string>();
            //    entity.Property(r => r.IntervalHours);
            //    entity.Property(r => r.BaseTime).IsRequired();
            //    entity.Property(r => r.Message).HasMaxLength(500);
            //    entity.Property(r => r.Status).IsRequired().HasConversion<string>();
            //    entity.Property(r => r.IsActive).HasDefaultValue(true);
            //    entity.Property(r => r.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(r => r.Patient)
            //          .WithMany(p => p.Reminders)
            //          .HasForeignKey(r => r.PatientID)
            //          .OnDelete(DeleteBehavior.Restrict)
            //          .IsRequired();

            //    entity.HasOne(r => r.PrescriptionMed)
            //          .WithMany(pm => pm.Reminders)
            //          .HasForeignKey(r => r.PrescriptionMedID)
            //          .OnDelete(DeleteBehavior.SetNull)
            //          .IsRequired(false);

            //    entity.HasOne(r => r.Appointment)
            //          .WithMany(a => a.Reminders)
            //          .HasForeignKey(r => r.AppointmentID)
            //          .OnDelete(DeleteBehavior.SetNull)
            //          .IsRequired(false);

            //    entity.HasMany(r => r.Instances)
            //          .WithOne(i => i.Reminder)
            //          .HasForeignKey(i => i.ReminderID)
            //          .OnDelete(DeleteBehavior.Cascade);

            //    entity.HasIndex(r => r.PatientID);
            //    entity.HasIndex(r => new { r.PrescriptionMedID, r.AppointmentID });
            //});

            // ─────────────────────── ReminderInstance ───────────────────────
            //modelBuilder.Entity<ReminderInstance>(entity =>
            //{
            //    entity.HasKey(i => i.InstanceID);
            //    entity.Property(i => i.DueDateTime).IsRequired();
            //    entity.Property(i => i.Status).IsRequired().HasConversion<string>();
            //    entity.Property(i => i.ConfirmedAt);
            //    entity.Property(i => i.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            //    entity.HasOne(i => i.Reminder)
            //          .WithMany(r => r.Instances)
            //          .HasForeignKey(i => i.ReminderID)
            //          .OnDelete(DeleteBehavior.Cascade)
            //          .IsRequired();

            //    entity.HasOne(i => i.Intake)
            //          .WithOne(mi => mi.ReminderInstance)
            //          .HasForeignKey<MedicationsIntake>(mi => mi.ReminderInstanceID)
            //          .OnDelete(DeleteBehavior.SetNull)
            //          .IsRequired(false);

            //    entity.HasIndex(i => i.ReminderID);
            //    entity.HasIndex(i => i.DueDateTime);
            //    entity.HasIndex(i => i.Status);
            //});

            // ─────────────────────── Review ───────────────────────
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

                //entity.HasOne(r => r.Appointment)
                //      .WithMany(a => a.Reviews)
                //      .HasForeignKey(r => r.AppointmentID)
                //      .OnDelete(DeleteBehavior.SetNull);

                //entity.HasIndex(r => new { r.UserID, r.AppointmentID });
            });

            // ─────────────────────── ExternalFile ───────────────────────
            // داخل OnModelCreating
            modelBuilder.Entity<ExternalFile>(entity =>
            {
                entity.HasKey(f => f.FileID);

                entity.Property(f => f.FileUrl).IsRequired().HasMaxLength(500);
                entity.Property(f => f.PublicId).HasMaxLength(200);
                entity.Property(f => f.FileType).IsRequired().HasMaxLength(100);
                entity.Property(f => f.FileSize).IsRequired();
                entity.Property(f => f.UploadedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.Property(f => f.CategoryType).HasMaxLength(50);
                entity.Property(f => f.CategoryValue).HasMaxLength(50);
                entity.Property(f => f.UploadedByRole).HasMaxLength(50);

                // كل العلاقات Restrict — مفيش ولا Cascade ولا SetNull
                entity.HasOne(f => f.Patient)
                      .WithMany(p => p.Files)
                      .HasForeignKey(f => f.PatientID)
                      .OnDelete(DeleteBehavior.Restrict)   // ← Restrict
                      .IsRequired(false);

                entity.HasOne(f => f.Doctor)
                      .WithMany(d => d.Files)
                      .HasForeignKey(f => f.DoctorID)
                      .OnDelete(DeleteBehavior.Restrict)   // ← Restrict
                      .IsRequired(false);

                entity.HasOne(f => f.MedicalHistory)
                      .WithMany(mh => mh.Files)
                      .HasForeignKey(f => f.MedicalHistoryID)
                      .OnDelete(DeleteBehavior.Restrict)   // ← Restrict
                      .IsRequired(false);

                entity.HasIndex(f => new { f.PatientID, f.DoctorID, f.MedicalHistoryID });
                entity.HasIndex(f => new { f.CategoryType, f.CategoryValue });
            });

            // Configure NotificationLog
            modelBuilder.Entity<NotificationLog>(entity =>
            {
                entity.HasKey(e => e.Id);

                entity.Property(e => e.Id)
                    .ValueGeneratedOnAdd();

                entity.Property(e => e.PatientId)
                    .IsRequired();

                entity.Property(e => e.ReminderId)
                    .IsRequired();

                entity.Property(e => e.OccurrenceId)
                    .IsRequired();

                entity.Property(e => e.FcmToken)
                    .IsRequired()
                    .HasMaxLength(500);

                entity.Property(e => e.ScheduledTime)
                    .IsRequired();

                entity.Property(e => e.SentAt)
                    .IsRequired(false);

                entity.Property(e => e.CreatedAt)
                    .IsRequired()
                    .HasDefaultValueSql("GETUTCDATE()");

                //  CRITICAL INDEX: For fast querying of unsent, due notifications
                entity.HasIndex(e => new { e.PatientId, e.ScheduledTime, e.SentAt })
                    .HasName("IX_NotificationLogs_Due")
                    .HasFilter("[SentAt] IS NULL");

                // Foreign key to PatientDevices (optional, for referential integrity)
                // If your PatientDevice has a PatientId, you might want:
                // entity.HasOne<PatientDevice>()
                //     .WithMany()
                //     .HasForeignKey(e => e.FcmToken)
                //     .IsRequired(false);
            });

            modelBuilder.Entity<ReminderV2>()
                .Property(r => r.EndDateUtc)
                .HasConversion(
                    v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null,
                    v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null
                );
        }
        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries<BaseEntity>();

            foreach (var entry in entries)
            {
                if (entry.State == EntityState.Modified)
                {
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                }
            }
        }

    }
}
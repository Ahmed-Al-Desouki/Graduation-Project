

namespace HealthCare_.Models.Context
{
    public class HealthCarePlusContext : IdentityDbContext<ApplicationUser, IdentityRole<int>, int>
    {
        public HealthCarePlusContext(DbContextOptions<HealthCarePlusContext> options) : base(options) { }

        // DbSets
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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure ApplicationUser table
            modelBuilder.Entity<ApplicationUser>(b =>
            {
                b.ToTable("Users");
                b.Property(u => u.Id).HasColumnName("UserID");
            });

            // ------------------- Relationships -------------------
            modelBuilder.Entity<Prescription>()
                .HasOne(p => p.Patient)
                .WithMany(pt => pt.Prescriptions)
                .HasForeignKey(p => p.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Prescription>()
                .HasOne(p => p.Doctor)
                .WithMany(d => d.Prescriptions)
                .HasForeignKey(p => p.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Patient)
                .WithMany(pt => pt.Appointments)
                .HasForeignKey(a => a.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Doctor)
                .WithMany(d => d.Appointments)
                .HasForeignKey(a => a.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Slot)
                .WithOne(ds => ds.Appointment)
                .HasForeignKey<DoctorSlot>(ds => ds.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DoctorSlot>()
                .HasOne(ds => ds.Doctor)
                .WithMany(d => d.Slots)
                .HasForeignKey(ds => ds.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<MedicalHistory>()
                .HasOne(mh => mh.Patient)
                .WithMany(pt => pt.MedicalHistories)
                .HasForeignKey(mh => mh.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<MedicalRecord>()
                .HasOne(mr => mr.MedicalHistory)
                .WithMany(mh => mh.MedicalRecords)
                .HasForeignKey(mr => mr.HistoryID)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MedicalRecord>()
                .HasOne(mr => mr.Doctor)
                .WithMany(d => d.MedicalRecords)
                .HasForeignKey(mr => mr.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<MedicationsIntake>()
                .HasOne(mi => mi.PrescriptionMed)
                .WithMany(pm => pm.MedicationsIntakes)
                .HasForeignKey(mi => mi.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PrescriptionMed>()
                .HasOne(pm => pm.Prescription)
                .WithMany(p => p.Medications)
                .HasForeignKey(pm => pm.PrescriptionID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DosingSchedule>()
                .HasOne(ds => ds.PrescriptionMed)
                .WithMany(pm => pm.DosingSchedules)
                .HasForeignKey(ds => ds.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Reminder>()
                .HasOne(r => r.PrescriptionMed)
                .WithMany(pm => pm.Reminders)
                .HasForeignKey(r => r.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Reminder>()
                .HasOne(r => r.Appointment)
                .WithMany(a => a.Reminders)
                .HasForeignKey(r => r.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.Appointment)
                .WithMany(a => a.Reviews)
                .HasForeignKey(r => r.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Doctor>()
                .HasOne(d => d.User)
                .WithOne(u => u.Doctor)
                .HasForeignKey<Doctor>(d => d.UserID)
                .OnDelete(DeleteBehavior.NoAction);
            modelBuilder.Entity<Doctor>()
                .HasIndex(d => d.UserID).IsUnique();

            modelBuilder.Entity<Patient>()
                .HasOne(p => p.User)
                .WithOne(u => u.Patient)
                .HasForeignKey<Patient>(p => p.UserID)
                .OnDelete(DeleteBehavior.NoAction);
            modelBuilder.Entity<Patient>()
                .HasIndex(p => p.UserID).IsUnique();

            modelBuilder.Entity<SessionType>()
                .HasOne(st => st.Doctor)
                .WithMany(d => d.SessionTypes)
                .HasForeignKey(st => st.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DoctorWeeklySchedule>()
                .HasOne(dws => dws.Doctor)
                .WithMany(d => d.WeeklySchedules)
                .HasForeignKey(dws => dws.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<ExternalFile>(entity =>
            {
                entity.HasKey(f => f.FileID);
                entity.Property(f => f.FileUrl).IsRequired().HasMaxLength(1000);
                entity.Property(f => f.PublicId).IsRequired().HasMaxLength(500);
                entity.Property(f => f.FileType).HasMaxLength(100);

                entity.HasOne(f => f.Doctor)
                      .WithMany(d => d.Files)
                      .HasForeignKey(f => f.DoctorID)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(f => f.MedicalHistory)
                      .WithMany(mh => mh.Files)
                      .HasForeignKey(f => f.MedicalHistoryID)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(f => f.Patient)
                      .WithMany()
                      .HasForeignKey(f => f.PatientID)
                      .OnDelete(DeleteBehavior.Cascade);
            });
        }
    }
}

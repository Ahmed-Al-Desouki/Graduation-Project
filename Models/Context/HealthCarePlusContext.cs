using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Models.Context
{
    public class HealthCarePlusContext : DbContext
    {
        public HealthCarePlusContext(DbContextOptions<HealthCarePlusContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
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
        public DbSet<Attachment> Attachments { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Prescription -> Patient
            modelBuilder.Entity<Prescription>()
                .HasOne(p => p.Patient)
                .WithMany(pt => pt.Prescriptions)
                .HasForeignKey(p => p.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            // Prescription -> Doctor
            modelBuilder.Entity<Prescription>()
                .HasOne(p => p.Doctor)
                .WithMany(d => d.Prescriptions)
                .HasForeignKey(p => p.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // Appointment -> Patient
            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Patient)
                .WithMany(pt => pt.Appointments)
                .HasForeignKey(a => a.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            // Appointment -> Doctor
            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Doctor)
                .WithMany(d => d.Appointments)
                .HasForeignKey(a => a.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // Appointment -> DoctorSlot
            modelBuilder.Entity<Appointment>()
                .HasOne(a => a.Slot)
                .WithOne(ds => ds.Appointment)
                .HasForeignKey<DoctorSlot>(ds => ds.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            // DoctorSlot -> Doctor
            modelBuilder.Entity<DoctorSlot>()
                .HasOne(ds => ds.Doctor)
                .WithMany(d => d.Slots)
                .HasForeignKey(ds => ds.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // MedicalHistory -> Patient
            modelBuilder.Entity<MedicalHistory>()
                .HasOne(mh => mh.Patient)
                .WithMany(pt => pt.MedicalHistories)
                .HasForeignKey(mh => mh.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            // MedicalRecord -> MedicalHistory
            modelBuilder.Entity<MedicalRecord>()
                .HasOne(mr => mr.MedicalHistory)
                .WithMany(mh => mh.MedicalRecords)
                .HasForeignKey(mr => mr.HistoryID)
                .OnDelete(DeleteBehavior.Cascade);

            // MedicalRecord -> Doctor
            modelBuilder.Entity<MedicalRecord>()
                .HasOne(mr => mr.Doctor)
                .WithMany(d => d.MedicalRecords)
                .HasForeignKey(mr => mr.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // MedicationsIntake -> PrescriptionMed
            modelBuilder.Entity<MedicationsIntake>()
                .HasOne(mi => mi.PrescriptionMed)
                .WithMany(pm => pm.MedicationsIntakes)
                .HasForeignKey(mi => mi.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            // PrescriptionMed -> Prescription
            modelBuilder.Entity<PrescriptionMed>()
                .HasOne(pm => pm.Prescription)
                .WithMany(p => p.Medications)
                .HasForeignKey(pm => pm.PrescriptionID)
                .OnDelete(DeleteBehavior.NoAction);

            // DosingSchedule -> PrescriptionMed
            modelBuilder.Entity<DosingSchedule>()
                .HasOne(ds => ds.PrescriptionMed)
                .WithMany(pm => pm.DosingSchedules)
                .HasForeignKey(ds => ds.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            // Reminder -> PrescriptionMed
            modelBuilder.Entity<Reminder>()
                .HasOne(r => r.PrescriptionMed)
                .WithMany(pm => pm.Reminders)
                .HasForeignKey(r => r.PrescriptionMedID)
                .OnDelete(DeleteBehavior.Cascade);

            // Reminder -> Appointment
            modelBuilder.Entity<Reminder>()
                .HasOne(r => r.Appointment)
                .WithMany(a => a.Reminders)
                .HasForeignKey(r => r.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            // Review -> User
            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserID)
                .OnDelete(DeleteBehavior.NoAction);

            // Review -> Appointment
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Appointment)
                .WithMany(a => a.Reviews)
                .HasForeignKey(r => r.AppointmentID)
                .OnDelete(DeleteBehavior.NoAction);

            // Doctor -> User
            modelBuilder.Entity<Doctor>()
                .HasOne(d => d.User)
                .WithOne(u => u.Doctor)
                .HasForeignKey<Doctor>(d => d.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // Patient -> User
            modelBuilder.Entity<Patient>()
                .HasOne(p => p.User)
                .WithOne(u => u.Patient)
                .HasForeignKey<Patient>(p => p.PatientID)
                .OnDelete(DeleteBehavior.NoAction);

            // SessionType -> Doctor
            modelBuilder.Entity<SessionType>()
                .HasOne(st => st.Doctor)
                .WithMany(d => d.SessionTypes)
                .HasForeignKey(st => st.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // DoctorWeeklySchedule -> Doctor
            modelBuilder.Entity<DoctorWeeklySchedule>()
                .HasOne(dws => dws.Doctor)
                .WithMany(d => d.WeeklySchedules)
                .HasForeignKey(dws => dws.DoctorID)
                .OnDelete(DeleteBehavior.NoAction);

            // Doctor -> Licenses
            modelBuilder.Entity<Doctor>()
                .HasMany(d => d.Licenses)
                .WithOne(a => a.DoctorLicense)
                .HasForeignKey(a => a.DoctorLicenseDoctorID)
                .OnDelete(DeleteBehavior.NoAction); // Changed to NoAction

            // Doctor -> Certificates
            modelBuilder.Entity<Doctor>()
                .HasMany(d => d.Certificates)
                .WithOne(a => a.DoctorCertificate)
                .HasForeignKey(a => a.DoctorCertificateDoctorID)
                .OnDelete(DeleteBehavior.NoAction); // Changed to NoAction

            // Doctor -> Bios
            modelBuilder.Entity<Doctor>()
                .HasMany(d => d.Bios)
                .WithOne(a => a.DoctorBio)
                .HasForeignKey(a => a.DoctorBioDoctorID)
                .OnDelete(DeleteBehavior.NoAction); // Changed to NoAction

            // MedicalHistory -> Attachments (LabTests, Radiology)
            modelBuilder.Entity<MedicalHistory>()
                .HasMany(mh => mh.LabTests)
                .WithOne()
                .HasForeignKey("MedicalHistoryID")
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MedicalHistory>()
                .HasMany(mh => mh.Radiology)
                .WithOne()
                .HasForeignKey("MedicalHistoryID")
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
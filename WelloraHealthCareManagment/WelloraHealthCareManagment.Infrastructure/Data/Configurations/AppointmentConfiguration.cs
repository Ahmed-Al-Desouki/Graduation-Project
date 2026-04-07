using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
    {
        public void Configure(EntityTypeBuilder<Appointment> builder)
        {
            builder.ToTable("Appointments");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.DoctorId)
                .IsRequired();

            builder.Property(x => x.Status)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(20)
                .HasDefaultValue(AppointmentStatus.Pending);

            builder.Property(x => x.PatientNotes)
                .HasMaxLength(1000);

            builder.Property(x => x.CancellationReason)
                .HasMaxLength(500);

            builder.Property(x => x.CancelledBy)
                .HasConversion<string>()
                .HasMaxLength(20);

            builder.Property(x => x.BookedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.IsPaid)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(x => x.ConsultationFee)
                .HasColumnType("decimal(18,2)");

            builder.Property(x => x.PaymentId);

            // Relationships

            builder.HasOne(x => x.TimeSlot)
                .WithOne(x => x.Appointment)
                .HasForeignKey<Appointment>(x => x.TimeSlotId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Payment)
                .WithOne(p => p.Appointment)
                .HasForeignKey<Payment>(p => p.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Patient)
                .WithMany()
                .HasForeignKey(x => x.PatientId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.MedicalRecord)
                .WithOne(x => x.Appointment)
                .HasForeignKey<AppointmentMedicalRecord>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.Prescriptions)
                .WithOne(x => x.Appointment)
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasMany(x => x.AccessGrants)
                .WithOne(x => x.Appointment)
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.NoAction);

            // Indexes
            builder.HasIndex(x => new { x.DoctorId, x.Status })
                .HasDatabaseName("IX_Appointments_Doctor_Status");

            builder.HasIndex(x => new { x.PatientId, x.Status })
                .HasDatabaseName("IX_Appointments_Patient_Status");

            builder.HasIndex(x => x.TimeSlotId)
                .IsUnique()
                .HasFilter("[Status] <> 'Cancelled' AND [Status] <> 'NoShow'")
                .HasDatabaseName("UQ_Appointment_TimeSlot");
        }
    }
}

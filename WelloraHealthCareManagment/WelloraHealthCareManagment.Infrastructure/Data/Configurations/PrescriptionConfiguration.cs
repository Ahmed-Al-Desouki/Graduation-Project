using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class PrescriptionConfiguration : IEntityTypeConfiguration<Prescription>
    {
        public void Configure(EntityTypeBuilder<Prescription> builder)
        {
            builder.ToTable("Prescriptions");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Id)
                .ValueGeneratedNever();

            builder.Property(x => x.DoctorId)
                .IsRequired()
                .HasColumnName("DoctorId");

            builder.Property(x => x.PrescriptionNumber)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(x => x.IssuedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.SpecialInstructions)
                .HasMaxLength(1000);

            builder.Property(x => x.DoctorSignature)
                .HasColumnType("nvarchar(max)");

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(x => x.Appointment)
                .WithMany(x => x.Prescriptions)
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Doctor)
                .WithMany(d => d.Prescriptions)
                .HasForeignKey(x => x.DoctorId)
                //.HasPrincipalKey(d => d.DoctorId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Patient)
                .WithMany()
                .HasForeignKey(x => x.PatientId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasMany(x => x.Items)
                   .WithOne(x => x.Prescription)
                   .HasForeignKey(x => x.PrescriptionId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Indexes
            builder.HasIndex(x => x.PrescriptionNumber)
                .IsUnique()
                .HasDatabaseName("UQ_PrescriptionNumber");

            builder.HasIndex(x => x.PatientId)
                .HasDatabaseName("IX_Prescriptions_PatientId");

            builder.HasIndex(x => x.AppointmentId)
                .HasDatabaseName("IX_Prescriptions_AppointmentId");
        }
    }
}
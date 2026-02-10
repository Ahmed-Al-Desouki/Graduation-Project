using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
{
    public class PrescriptionConfiguration : IEntityTypeConfiguration<Prescription>
    {
        public void Configure(EntityTypeBuilder<Prescription> builder)
        {
            builder.ToTable("Prescriptions");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.DoctorId)
                .IsRequired();

            builder.Property(x => x.PrescriptionNumber)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(x => x.SpecialInstructions)
                .HasMaxLength(1000);

            builder.Property(x => x.DoctorSignature)
                .HasColumnType("nvarchar(max)");

            builder.HasOne(x => x.Appointment)
                .WithMany(x => x.Prescriptions)
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Doctor)
                .WithMany()
                .HasForeignKey(x => x.DoctorId)
                .HasPrincipalKey(d => d.DoctorId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Patient)
                .WithMany()
                .HasForeignKey(x => x.PatientId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasMany(x => x.Items)
                .WithOne(x => x.Prescription)
                .HasForeignKey(x => x.PrescriptionId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => x.PrescriptionNumber)
                .IsUnique();

            builder.HasIndex(x => x.PatientId);
        }
    }
}

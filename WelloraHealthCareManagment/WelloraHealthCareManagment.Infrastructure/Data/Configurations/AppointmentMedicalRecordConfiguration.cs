using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class AppointmentMedicalRecordConfiguration : IEntityTypeConfiguration<AppointmentMedicalRecord>
    {
        public void Configure(EntityTypeBuilder<AppointmentMedicalRecord> builder)
        {
            builder.ToTable("AppointmentMedicalRecords");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.AppointmentId)
                .IsRequired();

            builder.Property(x => x.ChiefComplaint)
                .HasMaxLength(1000);

            builder.Property(x => x.VitalSigns)
                .HasColumnType("nvarchar(max)"); // JSON

            builder.Property(x => x.PhysicalExamination)
                .HasMaxLength(2000);

            builder.Property(x => x.Diagnosis)
                .IsRequired()
                .HasMaxLength(500);

            builder.Property(x => x.DiagnosisCode)
                .HasMaxLength(20); // ICD-10

            builder.Property(x => x.TreatmentPlan)
                .HasMaxLength(2000);

            builder.Property(x => x.DoctorNotes)
                .HasMaxLength(2000);

            builder.Property(x => x.FollowUpInstructions)
                .HasMaxLength(1000);

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(x => x.Appointment)
                .WithOne(x => x.MedicalRecord)
                .HasForeignKey<AppointmentMedicalRecord>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);

            // Indexes
            builder.HasIndex(x => x.AppointmentId)
                .IsUnique()
                .HasDatabaseName("UQ_AppointmentMedicalRecord");

            builder.HasIndex(x => x.DiagnosisCode)
                .HasDatabaseName("IX_MedicalRecords_DiagnosisCode");
        }
    }
}
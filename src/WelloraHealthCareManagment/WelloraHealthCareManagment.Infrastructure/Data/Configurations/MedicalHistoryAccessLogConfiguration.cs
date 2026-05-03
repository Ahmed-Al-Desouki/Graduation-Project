using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
{
    public class MedicalHistoryAccessLogConfiguration : IEntityTypeConfiguration<MedicalHistoryAccessLog>
    {
        public void Configure(EntityTypeBuilder<MedicalHistoryAccessLog> builder)
        {
            builder.ToTable("MedicalHistoryAccessLogs");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.DoctorId)
                   .IsRequired()
                   .HasColumnName("DoctorId");

            builder.Property(x => x.PatientId)
                   .IsRequired()
                   .HasColumnName("PatientId");

            builder.Property(x => x.AccessedAt)
                   .IsRequired();

            builder.Property(x => x.AccessType)
                   .IsRequired()
                   .HasMaxLength(50);

            builder.Property(x => x.ResourceAccessed)
                   .HasMaxLength(200);

            builder.Property(x => x.IpAddress)
                   .HasMaxLength(50);

            builder.Property(x => x.UserAgent)
                   .HasMaxLength(500);

            // العلاقة مع AccessGrant → Cascade (منطقي، لما يتمسح الـ grant يتمسح السجلات الخاصة بيه)
            builder.HasOne(x => x.AccessGrant)
                   .WithMany(x => x.AccessLogs)
                   .HasForeignKey(x => x.AccessGrantId)
                   .OnDelete(DeleteBehavior.Cascade);

            // العلاقة مع Doctor → NoAction (عشان نمنع تعارض)
            builder.HasOne(x => x.Doctor)
                   .WithMany(d => d.MedicalHistoryAccessLogs)
                   .HasForeignKey(x => x.DoctorId)
                   .OnDelete(DeleteBehavior.NoAction);

            // ──────────────── التعديل المهم ────────────────
            // العلاقة مع Patient → NoAction لحل مشكلة multiple cascade paths
            builder.HasOne(x => x.Patient)
                   .WithMany()                             // أو .WithMany(p => p.MedicalHistoryAccessLogs) لو موجودة
                   .HasForeignKey(x => x.PatientId)
                   .OnDelete(DeleteBehavior.NoAction);
            // ────────────────────────────────────────────────

            // Indexes
            builder.HasIndex(x => new { x.PatientId, x.AccessedAt })
                   .HasDatabaseName("IX_AccessLogs_Patient_Date");

            builder.HasIndex(x => x.DoctorId);
            builder.HasIndex(x => x.AccessGrantId);
        }
    }
}
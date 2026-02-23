using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using HealthCare_.Models.V2;

namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
{
    public class ReminderV2Configuration : IEntityTypeConfiguration<ReminderV2>
    {
        public void Configure(EntityTypeBuilder<ReminderV2> builder)
        {
            builder.HasKey(r => r.Id);

            // ✅ Composite Index للبحث السريع
            builder.HasIndex(r => new { r.PatientId, r.IsActive })
                .HasDatabaseName("IX_ReminderV2s_PatientId_IsActive");

            builder.HasIndex(r => new { r.DoctorId, r.IsActive })
                .HasDatabaseName("IX_ReminderV2s_DoctorId_IsActive");

            builder.HasIndex(r => r.PrescriptionId)
                .HasDatabaseName("IX_ReminderV2s_PrescriptionId");

            builder.HasIndex(r => r.PrescriptionItemId)
                .HasDatabaseName("IX_ReminderV2s_PrescriptionItemId");

            builder.Property(r => r.Title)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(r => r.Message)
                .HasMaxLength(1000);

            builder.Property(r => r.TimeZoneId)
                .HasMaxLength(50);

            // Relationships
            builder.HasOne(r => r.Prescription)
                .WithMany()
                .HasForeignKey(r => r.PrescriptionId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(r => r.PrescriptionItem)
                .WithMany()
                .HasForeignKey(r => r.PrescriptionItemId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
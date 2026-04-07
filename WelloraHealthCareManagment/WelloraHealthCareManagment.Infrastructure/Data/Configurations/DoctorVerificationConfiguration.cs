// Infrastructure/Data/Configurations/DoctorVerificationConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class DoctorVerificationConfiguration : IEntityTypeConfiguration<DoctorVerification>
    {
        public void Configure(EntityTypeBuilder<DoctorVerification> builder)
        {
            builder.HasKey(dv => dv.VerificationId);

            // Properties
            builder.Property(dv => dv.DoctorId).IsRequired();
            builder.Property(dv => dv.DocumentType)
                   .IsRequired()
                   .HasConversion<string>();

            builder.Property(dv => dv.Status)
                   .IsRequired()
                   .HasConversion<string>()
                   .HasDefaultValue(VerificationStatus.Pending);

            builder.Property(dv => dv.AdminNotes).HasMaxLength(1000);
            builder.Property(dv => dv.RejectionReason).HasMaxLength(1000);
            builder.Property(dv => dv.SubmittedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(dv => dv.Doctor)
                   .WithMany(d => d.Verifications)
                   .HasForeignKey(dv => dv.DoctorId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired();

            builder.HasOne(dv => dv.File)
                   .WithMany()
                   .HasForeignKey(dv => dv.FileId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired(false);

            builder.HasOne(dv => dv.ReviewedByAdmin)
                   .WithMany()
                   .HasForeignKey(dv => dv.ReviewedByAdminId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired(false);

            // Indexes for performance
            builder.HasIndex(dv => dv.DoctorId);
            builder.HasIndex(dv => dv.Status);
            builder.HasIndex(dv => new { dv.DoctorId, dv.Status });
            builder.HasIndex(dv => dv.SubmittedAt);
        }
    }
}
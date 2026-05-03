// Infrastructure/Data/Configurations/AdminActionLogConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.AdminLogs;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class AdminActionLogConfiguration : IEntityTypeConfiguration<AdminActionLog>
    {
        public void Configure(EntityTypeBuilder<AdminActionLog> builder)
        {
            builder.HasKey(aal => aal.Id);

            builder.Property(aal => aal.AdminId).IsRequired();
            builder.Property(aal => aal.ActionType).IsRequired().HasConversion<string>();
            builder.Property(aal => aal.TargetEntity).HasMaxLength(50).IsRequired();
            builder.Property(aal => aal.TargetId).HasMaxLength(50).IsRequired();
            builder.Property(aal => aal.Details).HasColumnType("nvarchar(max)");
            builder.Property(aal => aal.IpAddress).HasMaxLength(100);
            builder.Property(aal => aal.UserAgent).HasMaxLength(500);

            builder.HasOne(aal => aal.Admin)
                   .WithMany()
                   .HasForeignKey(aal => aal.AdminId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired();

            // Indexes for audit queries
            builder.HasIndex(aal => new { aal.AdminId, aal.CreatedAt });
            builder.HasIndex(aal => aal.ActionType);
            builder.HasIndex(aal => new { aal.TargetEntity, aal.TargetId });
            builder.HasIndex(aal => aal.CreatedAt);
        }
    }
}
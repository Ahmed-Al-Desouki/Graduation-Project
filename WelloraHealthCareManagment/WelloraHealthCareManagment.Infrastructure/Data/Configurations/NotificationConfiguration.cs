// Infrastructure/Data/Configurations/NotificationConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.Notifications;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
    {
        public void Configure(EntityTypeBuilder<Notification> builder)
        {
            builder.HasKey(n => n.Id);

            builder.Property(n => n.UserId).IsRequired();
            builder.Property(n => n.Title).HasMaxLength(200).IsRequired();
            builder.Property(n => n.Message).HasMaxLength(1000).IsRequired();
            builder.Property(n => n.Type).IsRequired().HasConversion<string>();
            builder.Property(n => n.RelatedEntityType).HasMaxLength(50);

            builder.HasOne(n => n.User)
                   .WithMany()
                   .HasForeignKey(n => n.UserId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .IsRequired();

            // Indexes for efficient querying
            builder.HasIndex(n => new { n.UserId, n.IsRead, n.CreatedAt });
            builder.HasIndex(n => n.Type);
        }
    }
}
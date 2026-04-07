// Infrastructure/Data/Configurations/TicketConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.Support;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class TicketConfiguration : IEntityTypeConfiguration<Ticket>
    {
        public void Configure(EntityTypeBuilder<Ticket> builder)
        {
            builder.HasKey(t => t.Id);

            builder.Property(t => t.UserId).IsRequired();
            builder.Property(t => t.Title).HasMaxLength(200).IsRequired();
            builder.Property(t => t.Description).HasMaxLength(2000).IsRequired();
            builder.Property(t => t.Category).IsRequired().HasConversion<string>();
            builder.Property(t => t.Status).IsRequired().HasConversion<string>();
            builder.Property(t => t.Priority).IsRequired().HasConversion<string>();

            builder.HasOne(t => t.User)
                   .WithMany()
                   .HasForeignKey(t => t.UserId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired();

            builder.HasOne(t => t.ClosedByAdmin)
                   .WithMany()
                   .HasForeignKey(t => t.ClosedByAdminId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired(false);

            builder.HasMany(t => t.Messages)
                   .WithOne(m => m.Ticket)
                   .HasForeignKey(m => m.TicketId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Indexes
            builder.HasIndex(t => new { t.UserId, t.Status, t.CreatedAt });
            builder.HasIndex(t => t.Status);
            builder.HasIndex(t => t.Category);
            builder.HasIndex(t => t.Priority);
        }
    }
}
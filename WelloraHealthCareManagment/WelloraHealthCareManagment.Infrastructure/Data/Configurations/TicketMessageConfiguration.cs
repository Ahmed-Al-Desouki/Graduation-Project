// Infrastructure/Data/Configurations/TicketMessageConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.Support;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class TicketMessageConfiguration : IEntityTypeConfiguration<TicketMessage>
    {
        public void Configure(EntityTypeBuilder<TicketMessage> builder)
        {
            builder.HasKey(tm => tm.Id);

            builder.Property(tm => tm.TicketId).IsRequired();
            builder.Property(tm => tm.SenderId).IsRequired();
            builder.Property(tm => tm.Message).HasMaxLength(2000).IsRequired();

            builder.HasOne(tm => tm.Ticket)
                   .WithMany(t => t.Messages)
                   .HasForeignKey(tm => tm.TicketId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .IsRequired();

            builder.HasOne(tm => tm.Sender)
                   .WithMany()
                   .HasForeignKey(tm => tm.SenderId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired();

            // Index for efficient message retrieval
            builder.HasIndex(tm => new { tm.TicketId, tm.CreatedAt });
        }
    }
}
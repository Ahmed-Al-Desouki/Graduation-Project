// Infrastructure/Data/Configurations/UserStatusConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class UserStatusConfiguration : IEntityTypeConfiguration<UserStatus>
    {
        public void Configure(EntityTypeBuilder<UserStatus> builder)
        {
            builder.HasKey(us => us.Id);

            builder.Property(us => us.UserId).IsRequired();
            builder.Property(us => us.BlockReason).HasMaxLength(500);
            builder.Property(us => us.SuspensionReason).HasMaxLength(500);

            // One-to-one with ApplicationUser
            builder.HasOne(us => us.User)
                   .WithOne(u => u.UserStatus)
                   .HasForeignKey<UserStatus>(us => us.UserId)
                   .OnDelete(DeleteBehavior.Cascade)
                   .IsRequired();

            // Optional relationships with admin users
            builder.HasOne(us => us.BlockedByAdmin)
                   .WithMany()
                   .HasForeignKey(us => us.BlockedByAdminId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired(false);

            builder.HasOne(us => us.SuspendedByAdmin)
                   .WithMany()
                   .HasForeignKey(us => us.SuspendedByAdminId)
                   .OnDelete(DeleteBehavior.Restrict)
                   .IsRequired(false);

            // Indexes for performance
            builder.HasIndex(us => us.UserId).IsUnique();
            builder.HasIndex(us => us.IsBlocked);
            builder.HasIndex(us => us.IsSuspended);
            builder.HasIndex(us => us.SuspensionEndDate);
        }
    }
}

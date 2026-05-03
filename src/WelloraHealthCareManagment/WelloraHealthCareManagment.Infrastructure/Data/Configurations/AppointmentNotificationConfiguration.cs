//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Builders;
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;

//namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
//{
//    public class AppointmentNotificationConfiguration : IEntityTypeConfiguration<AppointmentNotification>
//    {
//        public void Configure(EntityTypeBuilder<AppointmentNotification> builder)
//        {
//            builder.ToTable("AppointmentNotifications");
//            builder.HasKey(x => x.Id);

//            builder.Property(x => x.RecipientType).IsRequired().HasMaxLength(20);
//            builder.Property(x => x.NotificationType).IsRequired().HasMaxLength(50);
//            builder.Property(x => x.Message).IsRequired().HasMaxLength(1000);
//            builder.Property(x => x.DeliveryChannel).IsRequired().HasMaxLength(20);
//            builder.Property(x => x.DeliveryStatus)
//                .IsRequired()
//                .HasConversion<string>()
//                .HasMaxLength(20);

//            builder.HasOne(x => x.Appointment)
//                .WithMany(x => x.Notifications)
//                .HasForeignKey(x => x.AppointmentId)
//                .OnDelete(DeleteBehavior.Cascade);

//            builder.HasIndex(x => new { x.ScheduledFor, x.DeliveryStatus })
//                .HasDatabaseName("IX_Notifications_Schedule");
//        }
//    }
//}

//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Builders;
//using WelloraHealthCareManagement.Domain.Entities;
//using WelloraHealthCareManagement.Domain.Enums;

//namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
//{
//    public class TimeSlotConfiguration : IEntityTypeConfiguration<TimeSlot>
//    {
//        public void Configure(EntityTypeBuilder<TimeSlot> builder)
//        {
//            builder.ToTable("TimeSlots");

//            builder.HasKey(x => x.Id);

//            builder.Property(x => x.DoctorId)
//                .IsRequired()
//                .HasColumnName("DoctorId");

//            builder.Property(x => x.SlotDate)
//                .IsRequired()
//                .HasColumnType("date");

//            builder.Property(x => x.StartTime)
//                .IsRequired()
//                .HasColumnType("time");

//            builder.Property(x => x.EndTime)
//                .IsRequired()
//                .HasColumnType("time");

//            builder.Property(x => x.Status)
//                .IsRequired()
//                .HasConversion<string>()
//                .HasMaxLength(20)
//                .HasDefaultValue(SlotStatus.Available);

//            builder.Property(x => x.IsManuallyCreated)
//                .IsRequired()
//                .HasDefaultValue(false);

//            builder.Property(x => x.CreatedAt)
//                .IsRequired()
//                .HasDefaultValueSql("GETUTCDATE()");

//            builder.Property(x => x.UpdatedAt)
//                .IsRequired()
//                .HasDefaultValueSql("GETUTCDATE()");

//            // Relationships
//            builder.HasOne(x => x.Doctor)
//                .WithMany()
//                .HasForeignKey(x => x.DoctorId)
//                .HasPrincipalKey(d => d.DoctorID)
//                .OnDelete(DeleteBehavior.Cascade);

//            builder.HasOne(x => x.GeneratedFromTemplate)
//                .WithMany(x => x.GeneratedSlots)
//                .HasForeignKey(x => x.GeneratedFromTemplateId)
//                .OnDelete(DeleteBehavior.SetNull);

//            //builder.HasOne(x => x.Appointment)
//            //    .WithOne(x => x.TimeSlot)
//            //    .HasForeignKey<Appointment>(x => x.TimeSlotId)
//            //    .OnDelete(DeleteBehavior.Cascade);

//            // Indexes للأداء العالي
//            builder.HasIndex(x => new { x.DoctorId, x.SlotDate, x.Status })
//                .HasDatabaseName("IX_TimeSlots_Doctor_Date_Status");

//            // Filtered Index - للخانات المتاحة فقط (أسرع في البحث)
//            builder.HasIndex(x => new { x.Status, x.SlotDate })
//                .HasDatabaseName("IX_TimeSlots_Status_Date")
//                .HasFilter("[Status] = 'Available'");

//            // Unique constraint - منع التكرار
//            builder.HasIndex(x => new { x.DoctorId, x.SlotDate, x.StartTime })
//                .IsUnique()
//                .HasDatabaseName("UQ_DoctorSlot");
//        }
//    }
//}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class TimeSlotConfiguration : IEntityTypeConfiguration<TimeSlot>
    {
        public void Configure(EntityTypeBuilder<TimeSlot> builder)
        {
            builder.ToTable("TimeSlots");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.DoctorId)
                .IsRequired()
                .HasColumnName("DoctorId");

            builder.Property(x => x.SlotDate)
                .IsRequired()
                .HasColumnType("date");

            builder.Property(x => x.StartTime)
                .IsRequired()
                .HasColumnType("time");

            builder.Property(x => x.EndTime)
                .IsRequired()
                .HasColumnType("time");

            builder.Property(x => x.Status)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(20)
                .HasDefaultValue(SlotStatus.Available);

            builder.Property(x => x.IsManuallyCreated)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired();
                //.HasDefaultValueSql("GETUTCDATE()");

            builder.HasOne(x => x.Doctor)
                .WithMany(d => d.TimeSlots)
                .HasForeignKey(x => x.DoctorId)
                .HasPrincipalKey(d => d.DoctorId)
                .OnDelete(DeleteBehavior.NoAction)
                .IsRequired();

            builder.HasOne(x => x.GeneratedFromTemplate)
                .WithMany()
                .HasForeignKey(x => x.GeneratedFromTemplateId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);

            // Indexes
            builder.HasIndex(x => new { x.DoctorId, x.SlotDate, x.StartTime })
                .IsUnique()
                .HasDatabaseName("UQ_TimeSlot_DoctorDate");

            builder.HasIndex(x => x.Status)
                .HasDatabaseName("IX_TimeSlots_Status");

            builder.HasIndex(x => x.SlotDate)
                .HasDatabaseName("IX_TimeSlots_SlotDate");
        }
    }
}
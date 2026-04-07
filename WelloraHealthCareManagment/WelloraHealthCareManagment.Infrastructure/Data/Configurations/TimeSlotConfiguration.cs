
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.Reflection.Emit;
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

            //builder.HasOne(x => x.GeneratedFromTemplate)
            //    .WithMany()
            //    .HasForeignKey(x => x.GeneratedFromTemplateId)
            //    .OnDelete(DeleteBehavior.SetNull)
            //    .IsRequired(false);

            // Indexes
            builder.HasIndex(x => new { x.DoctorId, x.SlotDate, x.StartTime })
                .IsUnique()
                .HasDatabaseName("UQ_TimeSlot_DoctorDate");

            builder.HasIndex(x => x.Status)
                .HasDatabaseName("IX_TimeSlots_Status");

            builder.HasIndex(x => x.SlotDate)
                .HasDatabaseName("IX_TimeSlots_SlotDate");


            builder.HasIndex(s => new { s.DoctorId, s.SlotDate, s.Status })
                .HasDatabaseName("IX_TimeSlots_DoctorId_SlotDate_Status");

            // للـ GetSlotsForDaysInRangeAsync

            builder.HasIndex(s => new { s.DoctorId, s.SlotDate })
                .HasDatabaseName("IX_TimeSlots_DoctorId_SlotDate");
        }
    }
}
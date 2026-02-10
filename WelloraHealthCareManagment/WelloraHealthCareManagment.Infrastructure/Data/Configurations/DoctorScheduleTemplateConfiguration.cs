using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class DoctorScheduleTemplateConfiguration : IEntityTypeConfiguration<DoctorScheduleTemplate>
    {
        public void Configure(EntityTypeBuilder<DoctorScheduleTemplate> builder)
        {
            builder.ToTable("DoctorScheduleTemplates");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.TemplateName)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.DoctorId)
                .IsRequired()
                .HasColumnName("DoctorId");

            builder.Property(x => x.SlotDurationMinutes)
                .IsRequired();

            builder.Property(x => x.BufferTimeMinutes)
                .IsRequired()
                .HasDefaultValue(0);

            builder.Property(x => x.IsActive)
                .IsRequired()
                .HasDefaultValue(true);

            builder.Property(x => x.EffectiveFromDate)
                .IsRequired()
                .HasColumnType("date");

            builder.Property(x => x.EffectiveToDate)
                .HasColumnType("date");

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(x => x.Doctor)
                .WithMany(d => d.ScheduleTemplates)
                .HasForeignKey(x => x.DoctorId)
                .HasPrincipalKey(d => d.DoctorId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasMany(x => x.TimeRanges)
                .WithOne(x => x.ScheduleTemplate)
                .HasForeignKey(x => x.ScheduleTemplateId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.GeneratedSlots)
                .WithOne(x => x.GeneratedFromTemplate)
                .HasForeignKey(x => x.GeneratedFromTemplateId)
                .OnDelete(DeleteBehavior.SetNull);

            // Indexes للسرعة
            builder.HasIndex(x => new { x.DoctorId, x.IsActive })
                .HasDatabaseName("IX_DoctorScheduleTemplates_DoctorId_Active");

            builder.HasIndex(x => x.EffectiveFromDate)
                .HasDatabaseName("IX_DoctorScheduleTemplates_EffectiveFromDate");
        }
    }
}
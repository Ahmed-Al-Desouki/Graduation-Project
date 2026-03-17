//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Builders;
//using WelloraHealthCareManagement.Domain.Entities;

//namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
//{
//    public class ScheduleTimeRangeConfiguration : IEntityTypeConfiguration<ScheduleTimeRange>
//    {
//        public void Configure(EntityTypeBuilder<ScheduleTimeRange> builder)
//        {
//            builder.ToTable("ScheduleTimeRanges");

//            builder.HasKey(x => x.Id);

//            builder.Property(x => x.DayOfWeek)
//                .IsRequired()
//                .HasConversion<int>();

//            builder.Property(x => x.StartTime)
//                .IsRequired()
//                .HasColumnType("time");

//            builder.Property(x => x.EndTime)
//                .IsRequired()
//                .HasColumnType("time");

//            builder.Property(x => x.IsAvailable)
//                .IsRequired()
//                .HasDefaultValue(true);

//            builder.Property(x => x.CreatedAt)
//                .IsRequired()
//                .HasDefaultValueSql("GETUTCDATE()");

//            builder.Property(x => x.UpdatedAt)
//                .IsRequired();
//                //.HasDefaultValueSql("GETUTCDATE()");

//            // Relationships
//            builder.HasOne(x => x.ScheduleTemplate)
//                .WithMany(x => x.TimeRanges)
//                .HasForeignKey(x => x.ScheduleTemplateId)
//                .OnDelete(DeleteBehavior.Cascade);

//            // Indexes
//            builder.HasIndex(x => new { x.ScheduleTemplateId, x.DayOfWeek })
//                .HasDatabaseName("IX_ScheduleTimeRanges_TemplateId_Day");

//            // Unique constraint - منع التكرار
//            builder.HasIndex(x => new { x.ScheduleTemplateId, x.DayOfWeek, x.StartTime, x.EndTime })
//                .IsUnique()
//                .HasDatabaseName("UQ_ScheduleTimeRange");
//        }
//    }
//}
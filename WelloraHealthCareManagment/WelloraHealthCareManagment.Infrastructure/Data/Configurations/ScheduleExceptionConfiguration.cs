//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Builders;
//using WelloraHealthCareManagement.Domain.Entities;

//namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
//{
//    public class ScheduleExceptionConfiguration : IEntityTypeConfiguration<ScheduleException>
//    {
//        public void Configure(EntityTypeBuilder<ScheduleException> builder)
//        {
//            builder.ToTable("ScheduleExceptions");

//            builder.HasKey(x => x.Id);

//            builder.Property(x => x.DoctorId)
//                .IsRequired()
//                .HasColumnName("DoctorId");

//            builder.Property(x => x.ExceptionDate)
//                .IsRequired()
//                .HasColumnType("date");

//            builder.Property(x => x.ExceptionType)
//                .IsRequired()
//                .HasConversion<string>()
//                .HasMaxLength(20);

//            builder.Property(x => x.Reason)
//                .HasMaxLength(500);

//            builder.Property(x => x.CustomStartTime)
//                .HasColumnType("time");

//            builder.Property(x => x.CustomEndTime)
//                .HasColumnType("time");

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

//            // Indexes
//            builder.HasIndex(x => new { x.DoctorId, x.ExceptionDate })
//                .HasDatabaseName("IX_ScheduleExceptions_Doctor_Date");

//            // Unique constraint - طبيب واحد له exception واحد في اليوم
//            builder.HasIndex(x => new { x.DoctorId, x.ExceptionDate })
//                .IsUnique()
//                .HasDatabaseName("UQ_DoctorException");
//        }
//    }
//}
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class ScheduleExceptionConfiguration : IEntityTypeConfiguration<ScheduleException>
    {
        public void Configure(EntityTypeBuilder<ScheduleException> builder)
        {
            builder.ToTable("ScheduleExceptions");

            // Primary Key
            builder.HasKey(x => x.Id);

            // Columns
            builder.Property(x => x.DoctorId)
                .IsRequired();

            builder.Property(x => x.ExceptionDate)
                .IsRequired()
                .HasColumnType("date");

            builder.Property(x => x.ExceptionType)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(20);

            builder.Property(x => x.Reason)
                .HasMaxLength(500);

            builder.Property(x => x.CustomStartTime)
                .HasColumnType("time");

            builder.Property(x => x.CustomEndTime)
                .HasColumnType("time");

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired();
                //.HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            //builder.HasOne(x => x.Doctor)
            //       .WithMany()
            //       .HasForeignKey(x => x.DoctorId) // هذا العمود فقط
            //       .HasPrincipalKey(d => d.DoctorID)
            //       .OnDelete(DeleteBehavior.NoAction);

            // Unique Index: طبيب واحد له exception واحد في اليوم
            builder.HasIndex(x => new { x.DoctorId, x.ExceptionDate })
                .IsUnique()
                .HasDatabaseName("UQ_DoctorException");
        }
    }
}


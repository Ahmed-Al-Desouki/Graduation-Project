using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
{
    public class AppointmentMedicalRecordConfiguration : IEntityTypeConfiguration<AppointmentMedicalRecord>
    {
        public void Configure(EntityTypeBuilder<AppointmentMedicalRecord> builder)
        {
            builder.ToTable("AppointmentMedicalRecords");
            builder.HasKey(x => x.Id);

            builder.Property(x => x.ChiefComplaint).HasMaxLength(1000);
            builder.Property(x => x.VitalSigns).HasColumnType("nvarchar(max)");
            builder.Property(x => x.PhysicalExamination).HasColumnType("nvarchar(max)");
            builder.Property(x => x.Diagnosis).IsRequired().HasMaxLength(2000);
            builder.Property(x => x.DiagnosisCode).HasMaxLength(50);
            builder.Property(x => x.TreatmentPlan).HasColumnType("nvarchar(max)");
            builder.Property(x => x.DoctorNotes).HasColumnType("nvarchar(max)");
            builder.Property(x => x.FollowUpInstructions).HasMaxLength(1000);

            builder.HasOne(x => x.Appointment)
                .WithOne(x => x.MedicalRecord)
                .HasForeignKey<AppointmentMedicalRecord>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => x.AppointmentId)
                .IsUnique()
                .HasDatabaseName("UQ_AppointmentMedicalRecord");
        }
    }
}

//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Builders;
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
//using WelloraHealthCareManagement.Domain.Entities;

//namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
//{
//    public class MedicalHistoryAccessGrantConfiguration : IEntityTypeConfiguration<MedicalHistoryAccessGrant>
//    {
//        public void Configure(EntityTypeBuilder<MedicalHistoryAccessGrant> builder)
//        {
//            builder.ToTable("MedicalHistoryAccessGrants");
//            builder.HasKey(x => x.Id);

//            builder.Property(x => x.DoctorId)
//                .IsRequired()
//                .HasColumnName("DoctorId");

//            builder.Property(x => x.GrantType)
//                .IsRequired()
//                .HasConversion<string>()
//                .HasMaxLength(20);

//            builder.Property(x => x.RevocationReason).HasMaxLength(500);

//            builder.HasOne(x => x.Patient)
//                .WithMany()
//                .HasForeignKey(x => x.PatientId)
//                .OnDelete(DeleteBehavior.Cascade);

//            builder.HasOne(x => x.Doctor)
//                .WithMany()
//                .HasForeignKey(x => x.DoctorId)
//                .HasPrincipalKey(d => d.DoctorID)
//                .OnDelete(DeleteBehavior.NoAction);

//            builder.HasOne(x => x.Appointment)
//                .WithMany(x => x.AccessGrants)
//                .HasForeignKey(x => x.AppointmentId)
//                .OnDelete(DeleteBehavior.NoAction);

//            builder.HasMany(x => x.AccessLogs)
//                .WithOne(x => x.AccessGrant)
//                .HasForeignKey(x => x.AccessGrantId)
//                .OnDelete(DeleteBehavior.Cascade);

//            builder.HasIndex(x => new { x.PatientId, x.DoctorId });
//        }
//    }
//}
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Data.Configurations
{
    public class MedicalHistoryAccessGrantConfiguration : IEntityTypeConfiguration<MedicalHistoryAccessGrant>
    {
        public void Configure(EntityTypeBuilder<MedicalHistoryAccessGrant> builder)
        {
            builder.ToTable("MedicalHistoryAccessGrants");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.DoctorId)
                .IsRequired();

            builder.Property(x => x.GrantType)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(20);

            builder.Property(x => x.RevocationReason)
                .HasMaxLength(500);

            builder.HasOne(x => x.Patient)
                .WithMany()
                .HasForeignKey(x => x.PatientId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Doctor)
                .WithMany()
                .HasForeignKey(x => x.DoctorId)
                .HasPrincipalKey(d => d.DoctorId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Appointment)
                .WithMany(x => x.AccessGrants)
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasMany(x => x.AccessLogs)
                .WithOne(x => x.AccessGrant)
                .HasForeignKey(x => x.AccessGrantId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(x => new { x.PatientId, x.DoctorId });
        }
    }
}


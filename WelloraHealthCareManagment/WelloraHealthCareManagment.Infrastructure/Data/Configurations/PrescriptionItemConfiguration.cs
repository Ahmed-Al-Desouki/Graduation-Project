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
    public class PrescriptionItemConfiguration : IEntityTypeConfiguration<PrescriptionItem>
    {
        public void Configure(EntityTypeBuilder<PrescriptionItem> builder)
        {
            builder.ToTable("PrescriptionItems");
            builder.HasKey(x => x.Id);

            builder.Property(x => x.MedicationName).IsRequired().HasMaxLength(200);
            builder.Property(x => x.MedicationCode).HasMaxLength(50);
            builder.Property(x => x.Dosage).IsRequired().HasMaxLength(100);
            builder.Property(x => x.Frequency).IsRequired().HasMaxLength(100);
            builder.Property(x => x.Duration).IsRequired().HasMaxLength(100);
            builder.Property(x => x.Instructions).HasMaxLength(500);

            builder.HasOne(x => x.Prescription)
                .WithMany(x => x.Items)
                .HasForeignKey(x => x.PrescriptionId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}

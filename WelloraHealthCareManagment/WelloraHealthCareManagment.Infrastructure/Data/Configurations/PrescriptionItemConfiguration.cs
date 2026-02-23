using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class PrescriptionItemConfiguration : IEntityTypeConfiguration<PrescriptionItem>
    {
        public void Configure(EntityTypeBuilder<PrescriptionItem> builder)
        {
            builder.ToTable("PrescriptionItems");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.PrescriptionId)
                .IsRequired();

            builder.Property(x => x.Id)
                .ValueGeneratedOnAdd();   

            builder.Property(x => x.MedicationName)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(x => x.MedicationCode)
                .HasMaxLength(50);

            builder.Property(x => x.Dosage)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Frequency)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Duration)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(x => x.Quantity)
                .IsRequired();

            builder.Property(x => x.Instructions)
                .HasMaxLength(500);

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.HasOne(x => x.Prescription)
                   .WithMany(x => x.Items)
                   .HasForeignKey(x => x.PrescriptionId)
                   .OnDelete(DeleteBehavior.Cascade);


            // Indexes
            builder.HasIndex(x => x.PrescriptionId)
                .HasDatabaseName("IX_PrescriptionItems_PrescriptionId");

            builder.HasIndex(x => x.MedicationName)
                .HasDatabaseName("IX_PrescriptionItems_MedicationName");
        }
    }
}
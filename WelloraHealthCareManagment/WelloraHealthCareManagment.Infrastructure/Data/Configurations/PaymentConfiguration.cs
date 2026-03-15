// Infrastructure/Data/Configurations/PaymentConfiguration.cs

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Data.Configurations
{
    public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
    {
        public void Configure(EntityTypeBuilder<Payment> builder)
        {
            builder.ToTable("Payments");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.AppointmentId)
                .IsRequired();

            builder.Property(x => x.PatientId)
                .IsRequired();

            builder.Property(x => x.DoctorId)
                .IsRequired();

            builder.Property(x => x.PaymobOrderId)
                .HasMaxLength(100);

            builder.Property(x => x.PaymobTransactionId)
                .HasMaxLength(100);

            builder.Property(x => x.Amount)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            builder.Property(x => x.Currency)
                .HasMaxLength(3)
                .IsRequired();

            builder.Property(x => x.Status)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(20);

            builder.Property(x => x.Method)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(30);

            builder.Property(x => x.RefundAmount)
                .HasColumnType("decimal(18,2)");

            builder.Property(x => x.RefundReason)
                .HasConversion<string>()
                .HasMaxLength(30);

            builder.Property(x => x.FailureReason)
                .HasMaxLength(500);

            builder.Property(x => x.RefundNotes)
                .HasMaxLength(1000);

            builder.Property(x => x.PaymobCallbackData)
                .HasColumnType("nvarchar(max)");

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(x => x.UpdatedAt)
                .IsRequired();

            // Relationships
            builder.HasOne(x => x.Appointment)
                .WithOne(a => a.Payment)
                .HasForeignKey<Payment>(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.Patient)
                .WithMany()
                .HasForeignKey(x => x.PatientId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.HasOne(x => x.Doctor)
                .WithMany()
                .HasForeignKey(x => x.DoctorId)
                .OnDelete(DeleteBehavior.NoAction);

            // Indexes
            builder.HasIndex(x => x.AppointmentId)
                .IsUnique()
                .HasDatabaseName("UQ_Payment_Appointment");

            builder.HasIndex(x => x.PaymobOrderId)
                .HasDatabaseName("IX_Payments_PaymobOrderId");

            builder.HasIndex(x => x.PaymobTransactionId)
                .HasDatabaseName("IX_Payments_PaymobTransactionId");

            builder.HasIndex(x => new { x.PatientId, x.Status })
                .HasDatabaseName("IX_Payments_Patient_Status");

            builder.HasIndex(x => x.CreatedAt)
                .HasDatabaseName("IX_Payments_CreatedAt");
        }
    }
}
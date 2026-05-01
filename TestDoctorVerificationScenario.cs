using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Infrastructure.Services.Admin;

namespace TestDoctorVerificationScenario
{
    public class DoctorVerificationTest
    {
        private readonly HealthCarePlusContext _context;
        private readonly DoctorVerificationService _verificationService;
        private readonly ILogger<DoctorVerificationService> _logger;

        public DoctorVerificationTest(HealthCarePlusContext context, ILogger<DoctorVerificationService> logger)
        {
            _context = context;
            _logger = logger;
            
            // Initialize service with minimal dependencies for testing
            _verificationService = new DoctorVerificationService(
                null, // IDoctorVerificationRepository - will need to mock
                null, // IDoctorRepository - will need to mock  
                null, // INotificationService - will need to mock
                null, // IRealtimeService - will need to mock
                null, // IAdminAuditService - will need to mock
                null, // IEmailService - will need to mock
                null, // IMapper - will need to mock
                logger
            );
        }

        public async Task TestRejectedDoctorUpdateScenario()
        {
            Console.WriteLine("=== Testing Rejected Doctor Update Scenario ===");
            
            // Step 1: Find a doctor with rejected verification
            var rejectedDoctor = await FindRejectedDoctor();
            if (rejectedDoctor == null)
            {
                Console.WriteLine("No rejected doctors found. Creating test scenario...");
                await CreateTestRejectedDoctorScenario();
                rejectedDoctor = await FindRejectedDoctor();
            }

            if (rejectedDoctor == null)
            {
                Console.WriteLine("Could not create test scenario");
                return;
            }

            Console.WriteLine($"Found rejected doctor: {rejectedDoctor.DoctorId}");
            
            // Step 2: Check current status
            var currentStatus = DoctorVerificationPolicy.DetermineRequestStatus(rejectedDoctor.Verifications);
            Console.WriteLine($"Current verification status: {currentStatus}");
            
            // Step 3: Simulate document replacement (what should happen when doctor updates)
            var rejectedVerification = rejectedDoctor.Verifications
                .FirstOrDefault(v => v.Status == VerificationStatus.Rejected);
                
            if (rejectedVerification != null)
            {
                Console.WriteLine($"Replacing rejected document: {rejectedVerification.DocumentType}");
                
                // This simulates what ReplaceVerificationDocumentAsync does
                rejectedVerification.Status = VerificationStatus.Pending;
                rejectedVerification.ReviewedAt = null;
                rejectedVerification.AdminNotes = null;
                rejectedVerification.RejectionReason = null;
                rejectedVerification.UpdatedAt = DateTime.UtcNow;
                
                await _context.SaveChangesAsync();
                
                // Step 4: Check new status
                var newStatus = DoctorVerificationPolicy.DetermineRequestStatus(rejectedDoctor.Verifications);
                Console.WriteLine($"New verification status after replacement: {newStatus}");
                
                if (newStatus == DoctorVerificationRequestStatus.Pending)
                {
                    Console.WriteLine("✅ SUCCESS: Status correctly reverted to Pending");
                }
                else
                {
                    Console.WriteLine($"❌ ISSUE: Status should be Pending but is {newStatus}");
                }
            }
            else
            {
                Console.WriteLine("No rejected verification found to replace");
            }
        }

        private async Task<Doctor?> FindRejectedDoctor()
        {
            return await _context.Doctors
                .Include(d => d.User)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.File)
                .Include(d => d.Verifications)
                    .ThenInclude(v => v.ReviewedByAdmin)
                .FirstOrDefaultAsync(d => d.Verifications.Any(v => v.Status == VerificationStatus.Rejected));
        }

        private async Task CreateTestRejectedDoctorScenario()
        {
            Console.WriteLine("Creating test rejected doctor scenario...");
            
            // This would create a test doctor with rejected documents
            // For brevity, just showing the structure
            Console.WriteLine("Test scenario creation would go here...");
        }
    }

    // Test runner
    public class Program
    {
        public static async Task Main(string[] args)
        {
            // Setup would go here to initialize DbContext and run the test
            Console.WriteLine("Run this test in your actual application environment");
        }
    }
}

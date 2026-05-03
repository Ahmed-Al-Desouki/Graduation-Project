using HealthCare_.Models.V2;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Infrastructure.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions
{
    public class UserDeviceRepository : IUserDeviceRepository
    {
        private readonly HealthCarePlusContext _context;

        public UserDeviceRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<bool> DeviceExistsAsync(int patientId, string fcmToken)
        {
            return await _context.PatientDevices
                .AnyAsync(d => d.PatientId == patientId && d.FcmToken == fcmToken);
        }

        public async Task AddDeviceAsync(int patientId, string fcmToken)
        {
            var device = new PatientDevice
            {
                PatientId = patientId,
                FcmToken = fcmToken,
                CreatedAt = DateTime.UtcNow
            };

            await _context.PatientDevices.AddAsync(device);
            await _context.SaveChangesAsync();
        }

        public async Task RemoveDeviceAsync(int patientId, string fcmToken)
        {
            var devices = await _context.PatientDevices
                .Where(d => d.PatientId == patientId && d.FcmToken == fcmToken)
                .ToListAsync();

            _context.PatientDevices.RemoveRange(devices);
            await _context.SaveChangesAsync();
        }

        public async Task<List<string>> GetDeviceTokensAsync(int patientId)
        {
            return await _context.PatientDevices
                .Where(d => d.PatientId == patientId)
                .Select(d => d.FcmToken)
                .ToListAsync();
        }
        public async Task<List<string>> GetAllActiveDeviceTokensAsync(int userId, CancellationToken ct = default)
        {
            return await _context.PatientDevices
                .Where(d => d.PatientId == userId)
                .Select(d => d.FcmToken)
                .Distinct()
                .ToListAsync(ct);
        }
    }
}


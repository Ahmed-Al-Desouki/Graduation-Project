using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.RemindersInterface
{
    public interface IReminderV2Service
    {
        // Create & Update
        Task<ReminderV2> CreateAsync(int patientId, CreateReminderV2Dto dto);
        Task UpdateAsync(int reminderId, int patientId, UpdateReminderV2Dto dto);

        // Read
        Task<ReminderV2Dto> GetByIdAsync(int reminderId, int patientId);
        Task<List<ReminderV2Dto>> GetAllAsync(int patientId);
        Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId);
        Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30);

        // Actions
        Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, ReminderEnums.IntakeStatus intake = ReminderEnums.IntakeStatus.Taken);
        Task SnoozeOccurrenceAsync(int reminderId, DateTime originalDue, int patientId, int minutes = 15);
        Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId);

        // Delete
        Task SoftDeleteAsync(int reminderId, int patientId);
    }
}

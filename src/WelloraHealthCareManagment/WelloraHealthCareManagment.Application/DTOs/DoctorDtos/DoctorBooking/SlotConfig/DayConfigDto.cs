using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig
{
    public class DayConfigDto
    {
        public Guid Id { get; set; }
        public DayOfWeek DayOfWeek { get; set; }
        public string DayName { get; set; } = string.Empty;
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public int SlotDurationMinutes { get; set; }
        public int BufferTimeMinutes { get; set; }
        public bool IsActive { get; set; }
        public int EstimatedSlotsPerDay { get; set; }
    }
}

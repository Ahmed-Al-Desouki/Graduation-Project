using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig
{
    public class GenerateSlotsByConfigRequest
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool RegenerateExisting { get; set; } = false;
        public int BatchSize { get; set; } = 1000;

        // لو null يولّد لكل الأيام — لو فيها أيام محددة يولّد ليها بس
        public List<DayOfWeek>? OnlyForDays { get; set; } = null;
    }
}

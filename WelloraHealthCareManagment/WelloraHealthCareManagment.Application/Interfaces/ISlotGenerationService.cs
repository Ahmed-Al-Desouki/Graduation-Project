using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;

namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface ISlotGenerationService
    {
        Task<GenerateSlotsResponse> GenerateAsync(
            int doctorId,
            GenerateSlotsByConfigRequest request,
            CancellationToken ct = default);

        Task RegenerateForDayAsync(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct = default);

        Task RegenerateForSingleDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken ct = default);
    }
}

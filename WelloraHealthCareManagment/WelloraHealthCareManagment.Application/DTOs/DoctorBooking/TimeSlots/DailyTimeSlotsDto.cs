using System;
using System.Collections.Generic;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots
{
    public class GetDoctorTimeSlotsResponse
    {
        public int DoctorId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<DailySlotsDto> DailySlots { get; set; } = new();
    }

    public class DailySlotsDto
    {
        public DateTime Date { get; set; }
        public string DayOfWeek { get; set; } = string.Empty; 
        public List<TimeSlotDetailDto> Slots { get; set; } = new();
    }

    public class TimeSlotDetailDto
    {
        public Guid SlotId { get; set; }
        public DateTime SlotDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public SlotStatus Status { get; set; }
        public bool IsManuallyCreated { get; set; }
        public Guid? GeneratedFromTemplateId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // إضافات اختيارية لو الدكتور هو اللي شايف
        public Guid? AppointmentId { get; set; }           // null لو Available
        public string? PatientFullName { get; set; }           // null لو مش محجوز أو المريض مش عايز يشوفه
        public string? PatientNotes { get; set; }          // لو موجود و الدكتور شايف
    }
}
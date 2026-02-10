using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Domain.Factories
{

    /// Factory لتوليد TimeSlots من Schedule Template
    /// يُستخدم في Background Job

    public interface ITimeSlotGeneratorFactory
    {
    
        /// توليد خانات ليوم واحد فقط
        List<TimeSlot> GenerateSlotsForDate(
            DoctorScheduleTemplate template,
            DateTime date,
            ScheduleException? exception = null);

    
        /// توليد خانات لفترة كاملة (أسبوع، شهر، إلخ)
        List<TimeSlot> GenerateSlotsForPeriod(
            DoctorScheduleTemplate template,
            DateTime startDate,
            DateTime endDate,
            List<ScheduleException> exceptions);

    
        /// حساب عدد الخانات التي ستُولد (للتقدير فقط - بدون إنشاء)
        int EstimateSlotsCount(
            DoctorScheduleTemplate template,
            DateTime startDate,
            DateTime endDate);
    }
}
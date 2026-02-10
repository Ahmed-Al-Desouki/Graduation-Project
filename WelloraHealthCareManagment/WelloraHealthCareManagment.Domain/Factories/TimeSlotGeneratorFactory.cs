using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagement.Domain.Factories
{
    public class TimeSlotGeneratorFactory : ITimeSlotGeneratorFactory
    {
        public List<TimeSlot> GenerateSlotsForDate(
            DoctorScheduleTemplate template,
            DateTime date,
            ScheduleException? exception = null)
        {
            var slots = new List<TimeSlot>();

            // Check for Day Off
            if (exception?.ExceptionType == ExceptionType.DayOff)
                return slots; // Empty list - no slots for this day

            // Get Time Ranges for this day
            var dayOfWeek = date.DayOfWeek;
            List<(TimeSpan Start, TimeSpan End)> timeRanges;

            if (exception?.ExceptionType == ExceptionType.CustomHours)
            {
                // استخدام الساعات المخصصة
                timeRanges = new List<(TimeSpan, TimeSpan)>
                {
                    (exception.CustomStartTime!.Value, exception.CustomEndTime!.Value)
                };
            }
            else
            {
                // استخدام الجدول العادي
                timeRanges = template.TimeRanges
                    .Where(tr => tr.DayOfWeek == dayOfWeek && tr.IsAvailable)
                    .Select(tr => (tr.StartTime, tr.EndTime))
                    .ToList();
            }

            // Generate slots for each time range
            foreach (var (start, end) in timeRanges)
            {
                var rangeSlots = GenerateSlotsForTimeRange(
                    template.DoctorId,
                    template.Id,
                    date,
                    start,
                    end,
                    template.SlotDurationMinutes,
                    template.BufferTimeMinutes
                );

                slots.AddRange(rangeSlots);
            }

            return slots;
        }

        public List<TimeSlot> GenerateSlotsForPeriod(
            DoctorScheduleTemplate template,
            DateTime startDate,
            DateTime endDate,
            List<ScheduleException> exceptions)
        {
            var allSlots = new List<TimeSlot>();
            var exceptionsDict = exceptions.ToDictionary(e => e.ExceptionDate.Date);

            var currentDate = startDate.Date;
            while (currentDate <= endDate.Date)
            {
                // Check if date is within template effective dates
                if (!template.IsEffectiveOn(currentDate))
                {
                    currentDate = currentDate.AddDays(1);
                    continue;
                }

                exceptionsDict.TryGetValue(currentDate, out var exception);

                var dailySlots = GenerateSlotsForDate(template, currentDate, exception);
                allSlots.AddRange(dailySlots);

                currentDate = currentDate.AddDays(1);
            }

            return allSlots;
        }

        public int EstimateSlotsCount(
            DoctorScheduleTemplate template,
            DateTime startDate,
            DateTime endDate)
        {
            // حساب تقريبي بدون إنشاء الخانات فعلياً
            int count = 0;
            var currentDate = startDate.Date;

            while (currentDate <= endDate.Date)
            {
                if (!template.IsEffectiveOn(currentDate))
                {
                    currentDate = currentDate.AddDays(1);
                    continue;
                }

                var dayOfWeek = currentDate.DayOfWeek;
                var timeRanges = template.TimeRanges
                    .Where(tr => tr.DayOfWeek == dayOfWeek && tr.IsAvailable);

                foreach (var range in timeRanges)
                {
                    var duration = range.EndTime - range.StartTime;
                    var slotDuration = TimeSpan.FromMinutes(template.SlotDurationMinutes);
                    var buffer = TimeSpan.FromMinutes(template.BufferTimeMinutes);

                    count += (int)(duration / (slotDuration + buffer));
                }

                currentDate = currentDate.AddDays(1);
            }

            return count;
        }

        /// توليد الخانات لفترة زمنية واحدة (مثل 10:00 - 14:00)
        private List<TimeSlot> GenerateSlotsForTimeRange(
            int doctorId, 
            Guid templateId,
            DateTime date,
            TimeSpan startTime,
            TimeSpan endTime,
            int slotDurationMinutes,
            int bufferTimeMinutes)
        {
            var slots = new List<TimeSlot>();
            var currentTime = startTime;
            var slotDuration = TimeSpan.FromMinutes(slotDurationMinutes);
            var buffer = TimeSpan.FromMinutes(bufferTimeMinutes);

            while (currentTime.Add(slotDuration) <= endTime)
            {
                var slotEndTime = currentTime.Add(slotDuration);

                var slot = TimeSlot.CreateFromTemplate(
                    doctorId,
                    date,
                    currentTime,
                    slotEndTime,
                    templateId
                );

                slots.Add(slot);
                currentTime = slotEndTime.Add(buffer);
            }

            return slots;
        }
    }
}
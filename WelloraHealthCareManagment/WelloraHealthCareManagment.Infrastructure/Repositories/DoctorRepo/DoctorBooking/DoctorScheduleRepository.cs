//using Microsoft.EntityFrameworkCore;
//using WelloraHealthCareManagement.Domain.Entities;
//using WelloraHealthCareManagement.Infrastructure.Data;
//using WelloraHealthCareManagment.API.Context;

//namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
//{
//    public class DoctorScheduleRepository : IDoctorScheduleRepository
//    {
//        private readonly HealthCarePlusContext _context;

//        public DoctorScheduleRepository(HealthCarePlusContext context)
//        {
//            _context = context;
//        }

//        public async Task<DoctorScheduleTemplate?> GetActiveTemplateAsync(
//            int doctorId,
//            CancellationToken cancellationToken = default)
//        {
//            var now = DateTime.UtcNow.Date;

//            return await _context.DoctorScheduleTemplates
//                .Include(t => t.TimeRanges)
//                .Where(t => t.DoctorId == doctorId
//                    && t.IsActive
//                    && t.EffectiveFromDate <= now
//                    && (t.EffectiveToDate == null || t.EffectiveToDate >= now))
//                .OrderByDescending(t => t.EffectiveFromDate)
//                .FirstOrDefaultAsync(cancellationToken);
//        }

//        public async Task<DoctorScheduleTemplate?> GetByIdWithDetailsAsync(
//            Guid templateId,
//            CancellationToken cancellationToken = default)
//        {
//            return await _context.DoctorScheduleTemplates
//                .Include(t => t.TimeRanges)
//                .FirstOrDefaultAsync(t => t.Id == templateId, cancellationToken);
//        }

//        public async Task<List<DoctorScheduleTemplate>> GetActiveTemplatesAsync(
//            int doctorId,
//            CancellationToken cancellationToken = default)
//        {
//            return await _context.DoctorScheduleTemplates
//                .Include(t => t.TimeRanges)
//                .Where(t => t.DoctorId == doctorId && t.IsActive)
//                .OrderByDescending(t => t.EffectiveFromDate)
//                .ToListAsync(cancellationToken);
//        }

//        public async Task<List<int>> GetDoctorsWithActiveSchedulesAsync(
//            CancellationToken cancellationToken = default)
//        {
//            var now = DateTime.UtcNow.Date;

//            return await _context.DoctorScheduleTemplates
//                .Where(t => t.IsActive
//                    && t.EffectiveFromDate <= now
//                    && (t.EffectiveToDate == null || t.EffectiveToDate >= now))
//                .Select(t => t.DoctorId)
//                .Distinct()
//                .ToListAsync(cancellationToken);
//        }

//        public async Task AddAsync(
//            DoctorScheduleTemplate template,
//            CancellationToken cancellationToken = default)
//        {
//            await _context.DoctorScheduleTemplates.AddAsync(template, cancellationToken);
//        }

//        //public async Task UpdateAsync(
//        //    DoctorScheduleTemplate template,
//        //    CancellationToken cancellationToken = default)
//        //{
//        //    _context.DoctorScheduleTemplates.Update(template);
//        //    await Task.CompletedTask;
//        //}
//        public async Task UpdateAsync(
//            DoctorScheduleTemplate template,
//            CancellationToken cancellationToken = default)
//        {
//            // Update الـ template بـ EF عادي بس من غير TimeRanges
//            var templateEntry = _context.Entry(template);
//            templateEntry.State = EntityState.Modified;

//            // Detach الـ TimeRanges عشان EF ميتعاملش معاهم
//            foreach (var range in template.TimeRanges)
//            {
//                var rangeEntry = _context.Entry(range);
//                rangeEntry.State = EntityState.Detached;
//            }

//            // Handle كل TimeRange بـ Raw SQL منفصل
//            foreach (var range in template.TimeRanges)
//            {
//                var now = DateTime.UtcNow;

//                await _context.Database.ExecuteSqlRawAsync(
//                    @"IF EXISTS (SELECT 1 FROM ScheduleTimeRanges WHERE Id = {0})
//                UPDATE ScheduleTimeRanges 
//                SET IsAvailable = {1}, StartTime = {2}, EndTime = {3}, 
//                    DayOfWeek = {4}, UpdatedAt = {5}
//                WHERE Id = {0}
//              ELSE
//                INSERT INTO ScheduleTimeRanges 
//                    (Id, ScheduleTemplateId, DayOfWeek, StartTime, EndTime, IsAvailable, CreatedAt, UpdatedAt)
//                VALUES ({0}, {6}, {4}, {2}, {3}, {1}, {5}, {5})",
//                    range.Id,                  // {0}
//                    range.IsAvailable,         // {1}
//                    range.StartTime,           // {2}
//                    range.EndTime,             // {3}
//                    (int)range.DayOfWeek,      // {4}
//                    now,                       // {5}
//                    range.ScheduleTemplateId   // {6}
//                ); 
//            }
//        }
//        public async Task<DoctorScheduleTemplate?> GetActiveTemplateWithTimeRangesAsync(
//            int doctorId,
//            CancellationToken cancellationToken = default)
//        {
//            var now = DateTime.UtcNow.Date;

//            return await _context.DoctorScheduleTemplates
//                .Include(t => t.TimeRanges)
//                .Where(t => t.DoctorId == doctorId && t.IsActive)
//                .Where(t => t.EffectiveFromDate <= now)
//                .Where(t => t.EffectiveToDate == null || t.EffectiveToDate >= now)
//                .OrderByDescending(t => t.EffectiveFromDate)
//                .FirstOrDefaultAsync(cancellationToken);
//        }
//    }
//}
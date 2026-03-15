//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Diagnostics;
//using WelloraHealthCareManagement.Domain.Entities;

//namespace WelloraHealthCareManagement.Infrastructure.Data.Interceptors
//{
//    /// Automatically updates CreatedAt and UpdatedAt timestamps on save
//    /// Maintains clean separation between Domain and Infrastructure
//    public class UpdateTimestampsInterceptor : SaveChangesInterceptor
//    {
//        public override InterceptionResult<int> SavingChanges(
//            DbContextEventData eventData,
//            InterceptionResult<int> result)
//        {
//            UpdateTimestamps(eventData.Context);
//            return base.SavingChanges(eventData, result);
//        }

//        public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
//            DbContextEventData eventData,
//            InterceptionResult<int> result,
//            CancellationToken cancellationToken = default)
//        {
//            UpdateTimestamps(eventData.Context);
//            return base.SavingChangesAsync(eventData, result, cancellationToken);
//        }

//        private static void UpdateTimestamps(DbContext? context)
//        {
//            if (context == null) return;

//            var entries = context.ChangeTracker.Entries<BaseEntity>();
//            var utcNow = DateTime.UtcNow;

//            foreach (var entry in entries)
//            {
//                switch (entry.State)
//                {
//                    case EntityState.Added:
//                        entry.Entity.CreatedAt = utcNow;
//                        entry.Entity.UpdatedAt = utcNow;
//                        break;

//                    case EntityState.Modified:
//                        entry.Entity.UpdatedAt = utcNow;
//                        // Prevent updating CreatedAt
//                        entry.Property(e => e.CreatedAt).IsModified = false;
//                        break;
//                }
//            }
//        }
//    }
//}
// Infrastructure/Data/Interceptors/UpdateTimestampInterceptor.cs

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Infrastructure.Data.Interceptors
{
    public class UpdateTimestampsInterceptor : SaveChangesInterceptor
    {
        public override InterceptionResult<int> SavingChanges(
            DbContextEventData eventData,
            InterceptionResult<int> result)
        {
            UpdateTimestamps(eventData.Context);
            return base.SavingChanges(eventData, result);
        }

        public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
            DbContextEventData eventData,
            InterceptionResult<int> result,
            CancellationToken cancellationToken = default)
        {
            UpdateTimestamps(eventData.Context);
            return base.SavingChangesAsync(eventData, result, cancellationToken);
        }

        private static void UpdateTimestamps(DbContext? context)
        {
            if (context == null) return;

            var entries = context.ChangeTracker.Entries<BaseEntity>();

            foreach (var entry in entries)
            {
                if (entry.State == EntityState.Modified)
                {
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                }
            }
        }
    }
}
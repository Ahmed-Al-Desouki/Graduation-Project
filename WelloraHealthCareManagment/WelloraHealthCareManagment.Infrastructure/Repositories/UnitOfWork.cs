using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

/// <summary>
/// IMPORTANT: This class is registered as Scoped — one instance per HTTP request.
/// Do NOT use this class in Singleton services or Hangfire background jobs directly.
/// Hangfire jobs must create a new IServiceScope before resolving IUnitOfWork:
///   using var scope = _serviceProvider.CreateScope();
///   var uow = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
/// </summary>

namespace WelloraHealthCareManagement.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly HealthCarePlusContext _context;
        private IDbContextTransaction? _transaction;

        public UnitOfWork(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return await _context.SaveChangesAsync(cancellationToken);
        }
        public void Detach<T>(T entity) where T : class
        {
            _context.Entry(entity).State = EntityState.Detached;
        }

        //public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
        //{
        //    _transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        //}
        public async Task<IDbContextTransaction> BeginTransactionAsync(
            CancellationToken ct = default)
        {
            _transaction = await _context.Database.BeginTransactionAsync(ct);
            return _transaction;
        }
        public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
        {
            try
            {
                if (_transaction != null)
                    await _transaction.CommitAsync(cancellationToken);
            }
            catch
            {
                await RollbackTransactionAsync(cancellationToken);
                throw;
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
        {
            if (_transaction != null)
            {
                await _transaction.RollbackAsync(cancellationToken);
                await _transaction.DisposeAsync();
                _transaction = null;
            }
        }
    }
}

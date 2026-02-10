namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    /// Unit of Work - للتحكم في الـ Transactions
    ///  التحكم في الـ Transactions
    /// حفظ عدة entities مرة واحدة
    /// Rollback عند الخطأ
    public interface IUnitOfWork
    {
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
        Task BeginTransactionAsync(CancellationToken cancellationToken = default);
        Task CommitTransactionAsync(CancellationToken cancellationToken = default);
        Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
    }
}
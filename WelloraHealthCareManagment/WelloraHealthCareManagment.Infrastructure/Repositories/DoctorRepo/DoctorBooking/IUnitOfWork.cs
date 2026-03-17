namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    /// Unit of Work - للتحكم في الـ Transactions
    ///  التحكم في الـ Transactions
    /// حفظ عدة entities مرة واحدة
    /// Rollback عند الخطأ
    public interface IUnitOfWork
    {
        //Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
        Task BeginTransactionAsync(CancellationToken cancellationToken = default);
        Task CommitTransactionAsync(CancellationToken cancellationToken = default);
        Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
        void Detach<T>(T entity) where T : class;
    }
}
namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface IUserActivityService
    {
        Task UpdateLastActivityAsync(int userId, CancellationToken cancellationToken = default);
    }
}

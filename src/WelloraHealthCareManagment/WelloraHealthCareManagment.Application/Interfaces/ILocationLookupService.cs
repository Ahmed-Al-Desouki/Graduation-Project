namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface ILocationLookupService
    {
        Task<string> ResolveAddressAsync(double latitude, double longitude, CancellationToken cancellationToken = default);
    }
}

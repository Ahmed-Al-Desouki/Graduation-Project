// Application/UseCases/MedicalHistory/Surgery/Queries/GetSurgeries/GetSurgeriesQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries
{
    public class GetSurgeriesQuery
    {
        public int HistoryId { get; set; }

        public GetSurgeriesQuery(int historyId)
        {
            HistoryId = historyId;
        }
    }
}
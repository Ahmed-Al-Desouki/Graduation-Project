// Application/UseCases/MedicalHistory/SocialHistory/Queries/GetSocialHistory/GetSocialHistoryQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory
{
    public class GetSocialHistoryQuery
    {
        public int HistoryId { get; set; }

        public GetSocialHistoryQuery(int historyId)
        {
            HistoryId = historyId;
        }
    }
}
// Application/UseCases/MedicalHistory/SocialHistory/Queries/GetSocialHistoryForShare/GetSocialHistoryForShareQuery.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare
{
    public class GetSocialHistoryForShareQuery
    {
        public int PatientId { get; set; }

        public GetSocialHistoryForShareQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}
// Application/UseCases/MedicalHistory/SocialHistory/Commands/SoftDeleteSocialHistory/SoftDeleteSocialHistoryCommand.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistory.Commands.SoftDeleteSocialHistory
{
    public class SoftDeleteSocialHistoryCommand
    {
        public int SocialHistoryId { get; set; }
        public int HistoryId { get; set; }

        public SoftDeleteSocialHistoryCommand(int socialHistoryId, int historyId)
        {
            SocialHistoryId = socialHistoryId;
            HistoryId = historyId;
        }
    }
}
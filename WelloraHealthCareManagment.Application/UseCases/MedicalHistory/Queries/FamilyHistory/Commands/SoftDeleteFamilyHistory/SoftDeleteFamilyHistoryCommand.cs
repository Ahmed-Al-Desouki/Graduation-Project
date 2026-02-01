// Application/UseCases/MedicalHistory/FamilyHistory/Commands/SoftDeleteFamilyHistory/SoftDeleteFamilyHistoryCommand.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.SoftDeleteFamilyHistory
{
    public class SoftDeleteFamilyHistoryCommand
    {
        public int FamilyHistoryId { get; set; }
        public int HistoryId { get; set; }

        public SoftDeleteFamilyHistoryCommand(int familyHistoryId, int historyId)
        {
            FamilyHistoryId = familyHistoryId;
            HistoryId = historyId;
        }
    }
}
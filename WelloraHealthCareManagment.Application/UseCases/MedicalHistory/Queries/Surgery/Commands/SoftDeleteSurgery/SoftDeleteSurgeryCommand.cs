// Application/UseCases/MedicalHistory/Surgery/Commands/SoftDeleteSurgery/SoftDeleteSurgeryCommand.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.SoftDeleteSurgery
{
    public class SoftDeleteSurgeryCommand
    {
        public int SurgeryId { get; set; }
        public int HistoryId { get; set; }

        public SoftDeleteSurgeryCommand(int surgeryId, int historyId)
        {
            SurgeryId = surgeryId;
            HistoryId = historyId;
        }
    }
}
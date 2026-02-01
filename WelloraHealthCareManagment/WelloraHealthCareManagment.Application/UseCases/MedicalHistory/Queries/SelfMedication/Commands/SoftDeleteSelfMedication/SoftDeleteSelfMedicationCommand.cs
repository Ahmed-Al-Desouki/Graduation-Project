// Application/UseCases/MedicalHistory/SelfMedication/Commands/SoftDeleteSelfMedication/SoftDeleteSelfMedicationCommand.cs
namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.SoftDeleteSelfMedication
{
    public class SoftDeleteSelfMedicationCommand
    {
        public int SelfMedicationId { get; set; }

        public SoftDeleteSelfMedicationCommand(int selfMedicationId)
        {
            SelfMedicationId = selfMedicationId;
        }
    }
}
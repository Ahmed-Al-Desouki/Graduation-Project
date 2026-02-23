using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.DoctorAccess
{
    public record GetPatientMedicalProfileForDoctorQuery(
        int DoctorId,
        int PatientId,
        Guid AppointmentId);
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GetMedicalProfileFromShareToken
{
    public class GetMedicalProfileFromShareTokenQuery
    {
        public string Token { get; set; }

        public GetMedicalProfileFromShareTokenQuery(string token)
        {
            Token = token;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Search
{
    public class SpecializationListResponse
    {
        public List<string> Specializations { get; set; } = new();
        public int TotalCount { get; set; }
    }
}

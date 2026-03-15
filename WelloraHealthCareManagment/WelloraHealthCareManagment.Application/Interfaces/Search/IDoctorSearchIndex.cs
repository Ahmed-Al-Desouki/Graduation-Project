using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Search
{
    public interface IDoctorSearchIndex
    {
        void BuildNameIndex(IEnumerable<string> names);
        void BuildSpecializationIndex(IEnumerable<string> specializations);
        List<string> SearchNamesByPrefix(string prefix, int maxResults = 20);
        List<string> SearchSpecializationsByPrefix(string prefix, int maxResults = 20);
        void AddDoctor(string name, string specialization);
    }
}

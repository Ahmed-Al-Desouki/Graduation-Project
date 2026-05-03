using WelloraHealthCareManagment.Application.Interfaces.Search;
using WelloraHealthCareManagment.Domain.Entities.Search;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class DoctorSearchIndex : IDoctorSearchIndex
    {
        private readonly Trie _nameTrie = new();
        private readonly Trie _specializationTrie = new();

        public void BuildNameIndex(IEnumerable<string> names)
        {
            foreach (var name in names)
                if (!string.IsNullOrWhiteSpace(name))
                    _nameTrie.Insert(name);
        }

        public void BuildSpecializationIndex(IEnumerable<string> specializations)
        {
            foreach (var spec in specializations)
                if (!string.IsNullOrWhiteSpace(spec))
                    _specializationTrie.Insert(spec);
        }

        public List<string> SearchNamesByPrefix(string prefix, int maxResults = 20)
            => _nameTrie.GetWordsByPrefix(prefix, maxResults);

        public List<string> SearchSpecializationsByPrefix(string prefix, int maxResults = 20)
            => _specializationTrie.GetWordsByPrefix(prefix, maxResults);

        public void AddDoctor(string name, string specialization)
        {
            if (!string.IsNullOrWhiteSpace(name))
                _nameTrie.Insert(name);
            if (!string.IsNullOrWhiteSpace(specialization))
                _specializationTrie.Insert(specialization);
        }
    }
}

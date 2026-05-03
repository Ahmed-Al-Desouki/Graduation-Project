using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Entities.Search
{
    public class Trie
    {
        private readonly TrieNode _root = new();

        public void Insert(string word)
        {
            if (string.IsNullOrWhiteSpace(word)) return;
            var current = _root;
            foreach (var ch in Normalize(word))
            {
                if (!current.Children.TryGetValue(ch, out var next))
                {
                    next = new TrieNode();
                    current.Children[ch] = next;
                }
                current = next;
            }
            current.IsEndOfWord = true;
        }

        public List<string> GetWordsByPrefix(string prefix, int maxResults = 10)
        {
            var results = new List<string>();
            var node = FindNode(prefix);
            if (node is null) return results;

            var normalizedPrefix = Normalize(prefix);
            var stack = new Stack<(TrieNode Node, string Word)>();
            stack.Push((node, normalizedPrefix));

            while (stack.Count > 0 && results.Count < maxResults)
            {
                var (currentNode, currentWord) = stack.Pop();
                if (currentNode.IsEndOfWord)
                    results.Add(currentWord);
                foreach (var child in currentNode.Children)
                    stack.Push((child.Value, currentWord + child.Key));
            }
            return results;
        }

        private TrieNode? FindNode(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            var current = _root;
            foreach (var ch in Normalize(input))
            {
                if (!current.Children.TryGetValue(ch, out var next))
                    return null;
                current = next;
            }
            return current;
        }

        public static string Normalize(string input) =>
            input.Trim().ToLowerInvariant();
    }
}

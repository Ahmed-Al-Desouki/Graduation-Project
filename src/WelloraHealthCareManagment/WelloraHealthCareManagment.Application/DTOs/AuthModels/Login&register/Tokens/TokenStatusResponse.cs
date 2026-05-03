using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.AuthModels.Login_register.Tokens
{
    public class TokenStatusResponse
    {
        public DateTime CheckedAt { get; set; }
        public List<TokenCheckResult>? Tokens { get; set; }
        public string Summary { get; set; } = string.Empty;
    }

    public class TokenCheckResult
    {
        public string Type { get; set; } = string.Empty; // "access" or "refresh"
        public bool Valid { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public int ExpiresIn { get; set; }
        public bool Revoked { get; set; }
        public string? Reason { get; set; }
    }
}

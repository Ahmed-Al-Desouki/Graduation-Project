namespace WelloraHealthCareManagment.Application.Interfaces.Authentication.Tokens
{
    public class RefreshTokenResponse
    {

        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public string? Error { get; set; }

        public static RefreshTokenResponse Success(string accessToken, string refreshToken)
        {
            return new RefreshTokenResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken
            };
        }

        public static RefreshTokenResponse Failed(string error)
        {
            return new RefreshTokenResponse
            {
                Error = error
            };
        }
    } 
}
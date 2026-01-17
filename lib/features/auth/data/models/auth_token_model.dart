class AuthTokenModel {
  final String accessToken;
  final String refreshToken;

  AuthTokenModel({required this.accessToken, required this.refreshToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('accessToken') && json.containsKey('refreshToken')) {
      return AuthTokenModel(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
    } else {
      throw Exception('Failed to parse tokens from API response');
    }
  }
}

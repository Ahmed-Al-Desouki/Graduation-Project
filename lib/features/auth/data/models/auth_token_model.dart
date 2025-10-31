class AuthTokenModel {
  final String accessToken;
  final String refreshToken;

  AuthTokenModel({required this.accessToken, required this.refreshToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return AuthTokenModel(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }
}

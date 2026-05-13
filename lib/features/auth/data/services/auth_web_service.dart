import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:image_picker/image_picker.dart';

class AuthWebServices {
  final ApiService _apiService;
  AuthWebServices(this._apiService);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? address,
    XFile? profileImagePath,
    bool? twoFactorEnabled,
  }) async {
    final formData = FormData.fromMap({
      'FullName': fullName,
      'Email': email,
      'Password': password,
      'Role': role,
      'UpdatedAt': '',
      'TwoFactorEnabled': twoFactorEnabled ?? false,
      if (profileImagePath != null)
        'ProfileImageFile': await MultipartFile.fromFile(
          profileImagePath.path,
          filename: profileImagePath.name,
        ),
    });

    final response = await _apiService.post('Auth/register', formData);
    return response;
  }

  Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
    required String role,
  }) async {
    final body = {"idToken": idToken, "role": role};
    final response = await _apiService.post(
      'GoogleSginInAuth/google-login',
      body,
    );
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String otpCode = "",
    bool usePasskey = false,
  }) async {
    final body = {
      "Email": email,
      "Password": password,
      "otpCode": otpCode,
      "usePasskey": usePasskey,
    };
    final response = await _apiService.post('Auth/login', body);
    return response;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final body = {"Email": email};
    final response = await _apiService.post('password/forgot', body);
    return response;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = {
      "email": email,
      "token": token,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };

    final response = await _apiService.post('password/reset', body);
    return response;
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
    required String accessToken,
  }) async {
    final body = {"refreshToken": refreshToken, "accessToken": accessToken};
    final response = await _apiService.post('auth/refresh-token', body);
    return response;
  }

  Future<Map<String, dynamic>> checkToken() async {
    return await _apiService.get('auth/token-status-v2');
  }

  Future<Map<String, dynamic>> checkRefreshToken(String token) async {
    return await _apiService.get('auth/token-status-v2');
  }

  Future<Map<String, dynamic>> resendOtp({required String mfaToken}) async {
    final body = {"mfaToken": mfaToken};
    final response = await _apiService.post('mfa/resend', body);
    return response;
  }

  Future<void> registerDevice(String deviceId) async {
    await _apiService.post('auth/register-device', {"fcmToken": deviceId});
  }

  Future<void> unregisterDevice(String deviceId) async {
    await _apiService.delete(
      'auth/unregister-device',
      body: {"fcmToken": deviceId},
    );
  }

  Future<void> logout({required int userId, required String jti}) async {
    await _apiService.post('auth/logout', {"userId": userId, "jti": jti});
  }
}

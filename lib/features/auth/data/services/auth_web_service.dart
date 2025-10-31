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
}

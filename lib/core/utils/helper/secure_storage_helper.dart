import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);

    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _userIdKey);
  }

  static Future<void> updateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: newAccessToken);
    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
  }

  static Future<bool> hasTokens() async {
    final access = await _storage.read(key: _accessTokenKey);
    final refresh = await _storage.read(key: _refreshTokenKey);
    return access != null && refresh != null;
  }

  static Future<void> saveUserRoleAndId({
    required String role,
    required String userId,
  }) async {
    await _storage.write(key: _userRoleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<Map<String, String?>> getUserRole() async {
    final role = await _storage.read(key: _userRoleKey);
    return {'role': role};
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
}

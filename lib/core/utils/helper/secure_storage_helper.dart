import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';

  static const String _jtiKey = 'jti';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessTokenKey);
  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshTokenKey);
  static Future<void> saveDeviceId(String deviceId) async =>
      await _storage.write(key: _deviceIdKey, value: deviceId);
  static Future<String?> getDeviceId() async =>
      await _storage.read(key: _deviceIdKey);

  static Future<void> saveFullUserData({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
    required String jti,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userRoleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _jtiKey, value: jti);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<String?> getJti() async => await _storage.read(key: _jtiKey);
  static Future<String?> getUserName() async =>
      await _storage.read(key: _userNameKey);
  static Future<String?> getUserEmail() async =>
      await _storage.read(key: _userEmailKey);

  static Future<Map<String, String?>> getUserRole() async {
    final role = await _storage.read(key: _userRoleKey);
    return {'role': role};
  }

  static Future<String?> getUserRole1() async {
    return await _storage.read(key: _userRoleKey);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> updateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: newAccessToken);
    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
  }
}
